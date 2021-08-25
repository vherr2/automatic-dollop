defmodule Npf.Filings do
  @moduledoc """
  The boundary for the filing system.
  """

  import Ecto.Query

  alias Npf.Filings.Award
  alias Npf.Filings.Filing
  alias Npf.Filings.Organization

  alias Npf.Filings.Utils.Parser

  alias Npf.Repo

  @entities %{
    "awards" => Npf.Filings.Award,
    "filings" => Npf.Filings.Filing,
    "organizations" => Npf.Filings.Organization
  }

  @doc """
  Parses a Non-profit XML-formatted filing

  """
  def parse_upload(filepath) do
    document = File.read!(filepath)

    filer = upsert_filer(document)
    filing = insert_filing(document, filer)
    insert_awards(document, filing)

    {:ok, filing}
  end

  @spec upsert_filer(binary()) :: Organization.t()
  defp upsert_filer(document) do
    filer_attrs = Parser.parse_filer(document)

    %Organization{}
    |> Organization.changeset(filer_attrs)
    |> Repo.insert!(
      returning: true,
      conflict_target: [:ein],
      on_conflict: {:replace_all_except, [:id]}
    )
  end

  defp insert_filing(document, filer) do
    filing_attrs = Parser.parse_filing(document)

    %Filing{}
    |> Filing.changeset(filing_attrs)
    |> Ecto.Changeset.put_assoc(:filer, filer)
    |> Repo.insert!(
      returning: true,
      conflict_target: [:filer_id, :tax_period_begin_date, :tax_period_end_date],
      on_conflict: {:replace_all_except, [:id]}
    )
  end

  defp insert_awards(document, filing) do
    parsed_receivers =
      Parser.parse_receivers(document)
      |> Map.fetch!(:recipients)
      |> Map.update!(:award, fn awards ->
        Enum.map(awards, &Award.changeset(%Award{}, &1))
      end)
      |> Map.update!(:organization, fn organizations ->
        Enum.map(organizations, &Organization.changeset(%Organization{}, &1))
      end)

    awards =
      [parsed_receivers.organization, parsed_receivers.award]
      |> Enum.zip()
      |> Enum.map(fn {organization, award} ->
        receiver =
          Repo.insert!(organization,
            returning: true,
            conflict_target: [:ein],
            on_conflict: {:replace_all_except, [:id]}
          )

        award
        |> Ecto.Changeset.put_assoc(:filing, filing)
        |> Ecto.Changeset.put_assoc(:receiver, receiver)
        |> Repo.insert!(on_conflict: :nothing)
      end)

    {:ok, awards}
  end

  @doc """
  Returns the list of organizations.
  """
  def list_filings(params) do
    filters = Map.get(params, "filter", %{})

    Filing
    |> base_query(filters)
    |> join(:inner, [filing], awards in assoc(filing, :awards))
    |> preload([filing, awards], awards: awards)
    |> select([resource], resource)
    |> Repo.all()
  end

  @doc """
  Returns the list of receivers.
  """
  def list_receivers(params) do
    filters = Map.get(params, "filter", %{})

    Organization
    |> base_query(filters)
    |> join(:inner, [receiver], awards in assoc(receiver, :awards))
    |> distinct([receiver], receiver.id)
    |> select([receiver], receiver)
    |> Repo.all()
  end

  @doc """
  Returns a list of a given entity types.
  """
  def list_entities(entity, params) when entity in ["awards", "organizations"] do
    filters = Map.get(params, "filter", %{})
    search_query = Map.get(params, "search", "")

    @entities
    |> Map.fetch!(entity)
    |> base_query(filters)
    |> search(search_query)
    |> select([resource], resource)
    |> Repo.all()
  end

  @doc """
  Gets a single entity.

  Raises `Ecto.NoResultsError` if the Organization does not exist.
  """
  def get_entity("filings", params) do
    Npf.Filings.Filing
    |> Repo.get!(params["id"])
    |> Repo.preload([:awards])
  end
  
  def get_entity(entity, params) do
    @entities
    |> Map.fetch!(entity)
    |> Repo.get!(params["id"])
  end

  @spec base_query(module, map) :: Ecto.Query.t()
  defp base_query(resource_schema, filters) do
    resource_schema
    |> from([])
    |> apply_filters(filters)
  end

  @spec base_query(Ecto.Query.t(), map) :: Ecto.Query.t()
  defp apply_filters(query, filters) when map_size(filters) > 0 do
    {_table, schema} = query.from.source

    supported_filters =
      :fields
      |> schema.__schema__()
      |> Enum.map(&to_string/1)

    filters
    |> Enum.filter(fn {k, _v} -> k in supported_filters end)
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.reduce(query, fn {field, value}, acc_query ->
      Ecto.Query.where(acc_query, [resource], field(resource, ^field) == ^value)
    end)
  end

  defp apply_filters(query, _filters), do: query

  defp search(query, search_query) when search_query != "" do
    search_string = "%#{search_query}%"

    query
    |> Ecto.Query.where([entity], ilike(entity.name_line_1, ^search_string))
  end

  defp search(query, _search_query), do: query
end
