import Config

# Public hosting via scripts/start-local.sh sets PAIRS_HOSTING=1 so we do not
# inject Phoenix live-reload (it can sit over the board behind Cloudflare) or
# run a Brunch watcher. Use `mix phx.server` without that env for local UI work.
hosting? = System.get_env("PAIRS_HOSTING") == "1"

watchers =
  if hosting? do
    []
  else
    [
      node: [
        "node_modules/brunch/bin/brunch",
        "watch",
        cd: Path.expand("../assets", __DIR__)
      ]
    ]
  end

config :pairs_one, PairsOneWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: not hosting?,
  check_origin: false,
  secret_key_base: "zgIQx2yeWjd3sfVIyujnify1b/mvRHMRwsu4SWcoBz2ilOrPBFrqRjvGFonUTfAX",
  watchers: watchers

unless hosting? do
  config :pairs_one, PairsOneWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
        ~r{priv/gettext/.*(po)$},
        ~r{lib/pairs_one_web/views/.*(ex)$},
        ~r{lib/pairs_one_web/templates/.*(eex)$}
      ]
    ]
end

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
