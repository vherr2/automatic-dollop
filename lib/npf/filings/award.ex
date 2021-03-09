defmodule Npf.Filings.Award do
  use Npf.Schema
  import Ecto.Changeset

  @primary_key false

  schema "awards" do
    belongs_to :filing, Npf.Filings.Filing, primary_key: true
    belongs_to :receiver, Npf.Filings.Organization, primary_key: true

    field :purpose, :string
    field :amount, :integer

    timestamps()
  end

  @doc false
  def changeset(award, attrs) do
    award
    |> cast(attrs, [:purpose, :amount])
    |> validate_required([:purpose, :amount])
    |> assoc_constraint(:filing)
    |> assoc_constraint(:receiver)
  end
end
