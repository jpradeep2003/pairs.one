module Update exposing (update)

--

import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import String
import Phoenix.Presence exposing (PresenceState, presenceDiffDecoder, presenceStateDecoder, syncDiff, syncState)
import Phoenix.Push
import Phoenix.Socket
import PlayerStats exposing (..)
import PortsOut exposing (..)
import Types.Card exposing (..)
import Types.Game exposing (..)
import Types.Model exposing (..)
import Types.Msg exposing (..)
import Types.Player exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInputPlayerName name ->
            { model | playerName = name } ! []

        SetUserName ->
            let
                push =
                    Phoenix.Push.init "set_player_name" ("game:" ++ model.game.id)
                        |> Phoenix.Push.withPayload
                            (JE.object
                                [ ( "name", JE.string model.playerName )
                                , ( "player_id", JE.string model.playerId )
                                ]
                            )

                ( _, phxCmd ) =
                    Phoenix.Socket.push push model.phxSocket
            in
            model ! [ Cmd.map PhoenixMsg phxCmd, storeNameLocally model.playerName ]

        -- Chat
        OnInputMessage msg ->
            { model | chatMessage = msg } ! []

        SendMessage ->
            let
                push =
                    Phoenix.Push.init "new_chat_msg" ("game:" ++ model.game.id)
                        |> Phoenix.Push.withPayload
                            (JE.object
                                [ ( "player_id", JE.string model.playerId )
                                , ( "body", JE.string model.chatMessage )
                                ]
                            )

                ( _, phxCmd ) =
                    Phoenix.Socket.push push model.phxSocket
            in
            { model | chatMessage = "" } ! [ Cmd.map PhoenixMsg phxCmd ]

        ReceiveMessage raw ->
            let
                chatMessageDecoder : JD.Decoder ChatMessage
                chatMessageDecoder =
                    JD.map2 ChatMessage
                        (JD.field "player_id" JD.string)
                        (JD.field "body" JD.string)

                chatMessage =
                    case JD.decodeValue chatMessageDecoder raw of
                        Ok msg ->
                            msg

                        Err error ->
                            ChatMessage "" error

                messages =
                    chatMessage :: model.chatMessages

                cmd =
                    if chatMessage.playerId /= model.playerId then
                        playAudio "chat-msg"

                    else
                        Cmd.none
            in
            { model | chatMessages = messages } ! [ cmd ]

        -- UpdateGame with complete state
        UpdateGame raw ->
            case JD.decodeValue gameDecoder raw of
                Ok game ->
                    updateGame model game

                Err error ->
                    decoderError model error

        UpdateFocus raw ->
            case JD.decodeValue JD.bool raw of
                Ok value ->
                    { model | inFocus = value } ! []

                Err error ->
                    decoderError model error

        ReceiveCompressedGame raw ->
            model ! [ decompressAndUpdateGame raw ]

        SendCompressedGame patch ->
            model ! [ sendCompressedGame model patch ]

        SelectGameUrlInput ->
            model ! [ focus ".game-url" ]

        CopyUrl ->
            model ! [ copyUrl ".game-url" ]

        FlipCard index ->
            -- This check is needed because Chrome seems to process click events asynchrously, which may lead to race
            -- condition due to the fact that a tile gets clicked while it's no longer current player's turn.
            if model.playerTurn == model.game.turn || isLocal model.game then
                flipCard index model

            else
                model ! []

        ChangeTheme theme ->
            let
                game =
                    model.game

                game_ =
                    { game | theme = theme }
            in
            { model | game = game_ } ! []

        Replay ->
            replay model

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

        HandlePresenceState raw ->
            case JD.decodeValue (presenceStateDecoder playerPresenceDecoder) raw of
                Ok presenceState ->
                    let
                        newPresenceState =
                            model.phxPresences |> syncState presenceState
                    in
                    { model | phxPresences = newPresenceState } ! []

                Err error ->
                    let
                        _ =
                            Debug.log "Error" error
                    in
                    model ! []

        HandlePresenceDiff raw ->
            case JD.decodeValue (presenceDiffDecoder playerPresenceDecoder) raw of
                Ok presenceDiff ->
                    let
                        newPresenceState =
                            model.phxPresences |> syncDiff presenceDiff

                        game =
                            if isLocal model.game then
                                model.game

                            else
                                updateFromPresenceState model.game newPresenceState
                    in
                    { model | game = game, phxPresences = newPresenceState } ! []

                Err error ->
                    let
                        _ =
                            Debug.log "Error" error
                    in
                    model ! []


replay : Model -> ( Model, Cmd Msg )
replay model =
    let
        payload =
            gameEncoder model.game

        push =
            Phoenix.Push.init "replay_game" ("game:" ++ model.game.id)
                |> Phoenix.Push.withPayload payload

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.push push model.phxSocket
    in
    { model
        | isCompleted = False
        , moveHits = 0
        , moveKnownMisses = 0
        , moveNewMisses = 0
    }
        ! [ Cmd.map PhoenixMsg phxCmd, gameRestarted True ]


flipCard : Int -> Model -> ( Model, Cmd Msg )
flipCard index model =
    let
        game =
            model.game

        players =
            game.players

        flippedIds =
            if List.length game.cards.flipped == game.flips then
                [ index ]

            else
                List.Extra.unique (index :: game.cards.flipped)

        ( newTurn, matched, turnFinished ) =
            if List.length flippedIds == game.flips then
                let
                    firstValue =
                        flippedIds |> List.head |> Maybe.withDefault -1 |> cardValueAt game.cards

                    matched =
                        List.all (\id -> cardValueAt game.cards id == firstValue) flippedIds

                    newTurn =
                        if matched then
                            game.turn

                        else
                            (game.turn + 1) % List.length players
                in
                ( newTurn, matched, True )

            else
                ( game.turn, False, False )

        cards =
            game.cards

        newCleared =
            if matched then
                cards.cleared ++ flippedIds

            else
                cards.cleared

        newSeen =
            if matched then
                cards.seen

            else
                cards.seen
                    ++ flippedIds
                    |> List.Extra.unique

        newCards =
            { cards | cleared = newCleared, seen = newSeen, flipped = flippedIds }

        roundFinished =
            List.length newCleared == List.length cards.values

        updatePlayerStatsById : Player -> Player
        updatePlayerStatsById player =
            if player.id == model.playerId then
                player |> PlayerStats.updatePlayer cards flippedIds matched

            else
                player

        updatePlayerStatsByIndex : Int -> Player -> Player
        updatePlayerStatsByIndex i player =
            if model.playerTurn == i then
                player |> PlayerStats.updatePlayer cards flippedIds matched

            else
                player

        players_ =
            if turnFinished then
                if isLocal model.game then
                    List.indexedMap updatePlayerStatsByIndex players

                else
                    List.map updatePlayerStatsById players

            else
                players

        newPlayers =
            if roundFinished then
                PlayerStats.updatePlayers players_

            else
                players_

        newGame =
            { game | cards = newCards, players = newPlayers, turn = newTurn }

        playerTurn =
            if isLocal game && turnFinished && not matched then
                -- Only in case of local game are we overriding playerTurn
                if roundFinished then
                    newTurn

                else
                    (model.playerTurn + 1) % List.length model.game.players

            else
                model.playerTurn

        newModel =
            applyMoveCounts turnFinished matched flippedIds cards.seen
                { model | game = newGame, flippedIds = flippedIds, isCompleted = roundFinished, playerTurn = playerTurn }

        historyCmd =
            maybeSaveHistory model.isCompleted newModel
    in
    ( newModel, Cmd.batch [ sendGame newGame, historyCmd ] )


updateGame : Model -> Game -> ( Model, Cmd Msg )
updateGame model game =
    let
        gameStarting =
            model.game.turn == -1 && game.turn /= -1

        ( playReadyCmd, game_ ) =
            if gameStarting && not (isLocal game) then
                let
                    game_ =
                        { game | turn = 0 }
                in
                ( playAudio "ready", game_ )

            else
                ( Cmd.none, game )

        playFlipCmd =
            if game.cards.flipped /= model.game.cards.flipped && model.game.cards.flipped /= [] then
                playAudio "flip"

            else
                Cmd.none

        game__ =
            if isSolo game_ then
                { game_ | turn = 0 }

            else
                game_

        isCompleted =
            List.length game.cards.values == List.length game.cards.cleared && List.length game.cards.values > 0

        playerTurn_ =
            if isLocal game then
                game__.turn

            else
                playerTurn model.playerId game.players

        completedTurn =
            game.flips > 0
                && List.length game.cards.flipped == game.flips
                && List.length model.game.cards.flipped < game.flips

        matched =
            List.length game.cards.cleared > List.length model.game.cards.cleared

        newModel =
            applyMoveCounts completedTurn matched game.cards.flipped model.game.cards.seen
                { model
                    | game = game__
                    , flippedIds = game.cards.flipped
                    , playerTurn = playerTurn_
                    , isCompleted = isCompleted
                    , random = game.random
                }
    in
    newModel ! [ playReadyCmd, playFlipCmd, maybeSaveHistory model.isCompleted newModel ]


sendGame : Game -> Cmd Msg
sendGame game =
    compressAndSendGame game


sendCompressedGame : Model -> JE.Value -> Cmd Msg
sendCompressedGame model game =
    let
        push =
            Phoenix.Push.init "update_game" ("game:" ++ model.game.id)
                |> Phoenix.Push.withPayload game

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.push push model.phxSocket
    in
    Cmd.map PhoenixMsg phxCmd


decoderError : Model -> String -> ( Model, Cmd Msg )
decoderError model error =
    let
        _ =
            Debug.log "Decoder error" error
    in
    ( model, Cmd.none )


cardValueAt : CardData -> Int -> Int
cardValueAt cardData index =
    cardData.values |> List.drop index |> List.head |> Maybe.withDefault -1


maybeSaveHistory : Bool -> Model -> Cmd Msg
maybeSaveHistory wasCompleted model =
    if (not wasCompleted) && model.isCompleted then
        saveGameHistory (historyValue model)

    else
        Cmd.none


historyValue : Model -> JE.Value
historyValue model =
    let
        cardCount =
            List.length model.game.cards.values

        size =
            round (sqrt (toFloat cardCount))

        score =
            model.game.players
                |> List.map (\p -> toString p.score)
                |> String.join "-"

        turns =
            model.game.players |> List.map .turns |> List.sum

        inaccurateTurns =
            model.game.players |> List.map .inaccurateTurns |> List.sum

        accuracy =
            if turns == 0 then
                0

            else
                (toFloat turns - toFloat inaccurateTurns) / toFloat turns * 100 |> truncate
    in
    JE.object
        [ ( "id", JE.string model.game.id )
        , ( "theme", JE.string model.game.theme )
        , ( "size", JE.int size )
        , ( "score", JE.string score )
        , ( "accuracy", JE.int accuracy )
        , ( "hits", JE.int model.moveHits )
        , ( "knownMisses", JE.int model.moveKnownMisses )
        , ( "newMisses", JE.int model.moveNewMisses )
        ]


{-| Classify a finished two-card move using the seen set from *before* this move.
The latest flip is prepended, so the second box is List.head.
-}
applyMoveCounts : Bool -> Bool -> List Int -> List Int -> Model -> Model
applyMoveCounts turnFinished matched flippedIds seenIds model =
    if not turnFinished then
        model

    else
        let
            secondId =
                flippedIds |> List.head |> Maybe.withDefault -1

            secondWasSeen =
                List.member secondId seenIds
        in
        if matched then
            { model | moveHits = model.moveHits + 1 }

        else if secondWasSeen then
            { model | moveKnownMisses = model.moveKnownMisses + 1 }

        else
            { model | moveNewMisses = model.moveNewMisses + 1 }
