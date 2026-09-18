// Some native code to support our Elm app (including the ports)
$(function(){
  var idKey = 'pairs-one-player-id',
    nameKey = 'pairs-one-player',
    settingsKey = 'pairs-one-settings',
    seenNewsIdKey = "pairs-one-last-seen-news-id",
    playerId = localStorage.getItem(idKey),
    locale = $("html").attr("lang"),
    elm,
    playerName = localStorage.getItem(nameKey),
    s4 = function() {
      return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
    },
    base64ToArrayBuffer = function(base64) {
        var binary_string =  window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array( len );
        for (var i = 0; i < len; i++)        {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes;
    },
    arrayBufferToBase64 = function( buffer ) {
        var binary = '';
        var bytes = new Uint8Array( buffer );
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode( bytes[ i ] );
        }
        return window.btoa( binary );
    },
    newsBar = $(".news-bar"),
    seenNewsId = JSON.parse(localStorage.getItem(seenNewsIdKey) || 0),
    currentNewsId = newsBar.data("news-id");

  if (!playerId) {
    var uuid = s4() + s4() + s4() + s4();
    localStorage.setItem(idKey, uuid);
    playerId = uuid;
  }

  newsBar.children(".close").on("click", function() {
    newsBar.hide();
    localStorage.setItem(seenNewsIdKey, currentNewsId);
  });

  if (seenNewsId < currentNewsId) {
    newsBar.show();
  }

  $("#elm-game").each(
    function(i, el){
      var themes = $(el).data('themes');

      elm = Elm.Game.embed(el, {
        id: "" + $(el).data('id'), // because sometimes it comes as an number
        playerId: playerId,
        playerName: playerName || "",
        host: location.host,
        isSsl: location.protocol == "https:",
        themes: themes,
        locale: locale
      });

      // Elm ports
      elm.ports.playAudio.subscribe(function(audio){
        var audio = new Audio("/sounds/" + audio + ".mp3");
        audio.play();
      });

      elm.ports.compressAndSendGame.subscribe(function(game){
        var compressed = arrayBufferToBase64(
          LZString.compressToUint8Array(
            JSON.stringify(game)
          )
        );
        elm.ports.onSendCompressedGame.send(compressed);
      });

      elm.ports.decompressAndUpdateGame.subscribe(function(params){
        var game = JSON.parse(
          LZString.decompressFromUint8Array(
            base64ToArrayBuffer(params.game)
          )
        );
        elm.ports.onGameUpdate.send(game);
      });

      elm.ports.focus.subscribe( function(el){
        $(el).select();
      });

      elm.ports.copyUrl.subscribe( function(el){
        $(el).select();
        try {
          succeeded = document.execCommand("copy");
        } catch (err) {};
      });

      elm.ports.storeNameLocally.subscribe(function(name){
        localStorage.setItem('pairs-one-player', name);
      });

      var gameStartedAt = Date.now();
      var historyKey = "pairs-one-game-history";

      if (elm.ports.saveGameHistory) {
        elm.ports.saveGameHistory.subscribe(function(payload){
          var endedAt = Date.now();
          var entry = {
            score: payload.score,
            accuracy: payload.accuracy,
            durationMs: endedAt - gameStartedAt,
            startTime: new Date(gameStartedAt).toISOString(),
            endTime: new Date(endedAt).toISOString(),
            theme: payload.theme,
            size: payload.size,
            id: payload.id,
            hits: payload.hits,
            knownMisses: payload.knownMisses,
            newMisses: payload.newMisses
          };
          var history = [];
          try {
            history = JSON.parse(localStorage.getItem(historyKey) || "[]");
          } catch (err) {
            history = [];
          }
          if (!Array.isArray(history)) {
            history = [];
          }
          var alreadyStored = history.some(function(item){
            return item.id === entry.id && item.endTime === entry.endTime;
          });
        if (!alreadyStored) {
          history.unshift(entry);
          localStorage.setItem(historyKey, JSON.stringify(history.slice(0, 200)));
        }
        window.location.href = "/" + locale + "/user";
        });
      }

      if (elm.ports.gameRestarted) {
        elm.ports.gameRestarted.subscribe(function(){
          gameStartedAt = Date.now();
        });
      }

      window.addEventListener("focus", function(event){
        elm.ports.onFocusChange.send(true);
      }, true);

      window.addEventListener("blur", function(event){
        elm.ports.onFocusChange.send(false);
      }, true);
    }
  )

  var renderHistory = function(){
    var $body = $(".user-history__body");
    if (!$body.length) {
      return;
    }
    var history = [];
    try {
      history = JSON.parse(localStorage.getItem("pairs-one-game-history") || "[]");
    } catch (err) {
      history = [];
    }
    if (!Array.isArray(history) || history.length === 0) {
      $body.empty();
      $(".user-history__empty").removeClass("hidden");
      return;
    }
    $(".user-history__empty").addClass("hidden");
    var formatDuration = function(ms){
      var totalSeconds = Math.max(0, Math.round((ms || 0) / 1000));
      var minutes = Math.floor(totalSeconds / 60);
      var seconds = totalSeconds % 60;
      return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    };
    var formatTime = function(iso){
      if (!iso) {
        return "";
      }
      var date = new Date(iso);
      if (isNaN(date.getTime())) {
        return iso;
      }
      return date.toLocaleString();
    };
    var formatMoveCount = function(value){
      if (typeof value === "number") {
        return String(value);
      }
      return "—";
    };
    var formatAccuracy = function(value){
      if (typeof value === "number") {
        return value + "%";
      }
      return "—";
    };
    $body.empty();
    history.forEach(function(item){
      var size = item.size ? item.size + "x" + item.size : "";
      var row = $("<tr/>");
      row.append($("<td/>").text(formatAccuracy(item.accuracy)));
      row.append($("<td/>").text(formatDuration(item.durationMs)));
      row.append($("<td/>").text(formatMoveCount(item.hits)));
      row.append($("<td/>").text(formatMoveCount(item.knownMisses)));
      row.append($("<td/>").text(formatMoveCount(item.newMisses)));
      row.append($("<td/>").text(item.theme || ""));
      row.append($("<td/>").text(size));
      row.append($("<td/>").text(formatTime(item.startTime)));
      row.append($("<td/>").text(formatTime(item.endTime)));
      var $delete = $("<button/>", {
        type: "button",
        class: "btn btn-default btn-sm user-history__delete",
        title: "Delete this game",
        "data-id": item.id || "",
        "data-end": item.endTime || ""
      }).append($("<span/>", { class: "fa fa-close" }));
      row.append($("<td/>").append($delete));
      $body.append(row);
    });
  };

  renderHistory();

  $(document).on("click", ".user-history__delete", function(){
    var id = String($(this).data("id") || "");
    var endTime = String($(this).data("end") || "");
    var history = [];
    try {
      history = JSON.parse(localStorage.getItem("pairs-one-game-history") || "[]");
    } catch (err) {
      history = [];
    }
    if (!Array.isArray(history)) {
      history = [];
    }
    history = history.filter(function(item){
      return !(String(item.id || "") === id && String(item.endTime || "") === endTime);
    });
    localStorage.setItem("pairs-one-game-history", JSON.stringify(history));
    renderHistory();
  });

  $("#player-data input").attr("value", playerName);

  // GameSelector

  $(".elm-game-selector").each(
    function(i, el){
      var defaultSettings = {
        theme: "eighties",
        size: 6,
        players: 2,
        visibility: "public"
      },
        settings = JSON.parse(localStorage.getItem(settingsKey) || JSON.stringify(defaultSettings));

      var lockSoloLocal = $(el).is("[data-lock-solo-local]");

      elm = Elm.GameSettings.embed(el, {
        csrf: $(el).data("csrf"),
        locale: $("html").attr("lang"),
        themes: $(el).data("themes"),
        theme: settings.theme,
        size: settings.size,
        players: lockSoloLocal ? 1 : settings.players,
        visibility: lockSoloLocal ? "local" : settings.visibility,
        lockSoloLocal: lockSoloLocal
      });

      elm.ports.saveSettingsToLocalStorage.subscribe(function(params){
        if (lockSoloLocal) {
          var stored = {};
          try {
            stored = JSON.parse(localStorage.getItem(settingsKey) || "{}");
          } catch (err) {
            stored = {};
          }
          stored.theme = params.theme;
          stored.size = params.size;
          if (!stored.players) {
            stored.players = defaultSettings.players;
          }
          if (!stored.visibility) {
            stored.visibility = defaultSettings.visibility;
          }
          localStorage.setItem(settingsKey, JSON.stringify(stored));
        } else {
          localStorage.setItem(settingsKey, JSON.stringify(params));
        }
      });
    }
  );

  // Let Elm render first, then show everything together
  setTimeout(function(){ $("#main").addClass("visible") }, 0);
});
