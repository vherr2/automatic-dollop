defmodule NpfWeb.FilingView do
  use NpfWeb, :view

  alias Npf.Filings

  @spec render(String.t(), map) :: map
  def render(_, %{data: data}) when is_list(data) do
    Enum.map(data, &render_data(&1))
  end

  def render(_, %{data: data}), do: render_data(data)

  @spec render_data(map) :: map
  def render_data(data = %Filings.Filing{}) do
    data
    |> Map.take([:awards | Filings.Filing.__schema__(:fields)])
    |> Map.update!(:awards, fn awards ->
      Enum.map(awards, &render_data(&1))
    end)
  end

  def render_data(data = %struct{}), do: Map.take(data, struct.__schema__(:fields))
end
