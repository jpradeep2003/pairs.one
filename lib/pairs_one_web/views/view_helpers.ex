defmodule PairsOneWeb.ViewHelpers do
  @moduledoc """
  Helpers available across all views. Imported in web/web.ex.
  """
  def locale do
    PairsOneWeb.ControllerHelpers.locale()
  end

  def js_app_src(conn) do
    PairsOneWeb.Router.Helpers.static_path(conn, "/js/app.js") <> "?v=user-history-6"
  end
end
