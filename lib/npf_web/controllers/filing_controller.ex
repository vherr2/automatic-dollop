defmodule NpfWeb.FilingController do
  use NpfWeb, :controller

  import Ecto.Query

  alias Npf.Filings
  alias Npf.Repo

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, params = %{"resource" => resource}) when resource in ["awards", "organizations"] do
    data = Filings.list_entities(resource, params)

    render(conn, "#{resource}.json", data: data)
  end

  def index(conn, params = %{"resource" => "filings"}) do
    data = Filings.list_filings(params)

    render(conn, "filings.json", data: data)
  end

  def index(conn, params = %{"resource" => "receivers"}) do
    data = Filings.list_receivers(params)

    render(conn, "receivers.json", data: data)
  end

  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(NpfWeb.ErrorView)
    |> render(:"404")
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, params = %{"resource" => resource}) when resource in ["awards", "filings", "organizations"] do
    data = Filings.get_entity(resource, params)

    render(conn, "show.json", data: data)
  end

  def show(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(NpfWeb.ErrorView)
    |> render(:"404")
  end

  @spec file_upload(Plug.Conn.t(), map) :: Plug.Conn.t()
  def file_upload(conn, _params) do
    render(conn, "upload.html")
  end

  @spec upload(Plug.Conn.t(), map) :: Plug.Conn.t()
  def upload(conn, params) do
    filepath = params["filing"].path

    {:ok, filing} = Npf.Filings.parse_upload(filepath)

    conn
    |> put_flash(:info, "Filing uploaded successfully.")
    |> redirect(to: "/api/filings/#{filing.id}")
  end
end
