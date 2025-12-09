defmodule CodeEditorWeb.PageController do
  use CodeEditorWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
