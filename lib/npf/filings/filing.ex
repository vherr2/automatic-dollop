defmodule Npf.Filings.Filing do
  use Npf.Schema
  import Ecto.Changeset

  schema "filings" do
    belongs_to :filer, Npf.Filings.Organization
    has_many :awards, Npf.Filings.Award

    field :tax_period_begin_date, :date
    field :tax_period_end_date, :date

    timestamps()
  end

  @doc false
  def changeset(award, attrs) do
    award
    |> cast(attrs, [:tax_period_begin_date, :tax_period_end_date])
    |> validate_required([:tax_period_begin_date, :tax_period_end_date])
    |> assoc_constraint(:filer)
  end
end
