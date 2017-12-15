defmodule TelnyxWeb.PageController do
  use TelnyxWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
