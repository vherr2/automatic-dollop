defmodule Npf.Filings.Organization do
  use Npf.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :address_line_1, :string
    field :address_line_2, :string
    field :city, :string
    field :ein, :integer
    field :name_line_1, :string
    field :name_line_2, :string
    field :state, :string
    field :zip_code, :string

    has_many :filings, Npf.Filings.Filing, foreign_key: :filer_id
    has_many :awards, Npf.Filings.Award, foreign_key: :receiver_id

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [
      :address_line_1,
      :address_line_2,
      :city,
      :ein,
      :name_line_1,
      :name_line_2,
      :state,
      :zip_code
    ])
    |> validate_required([:address_line_1, :city, :name_line_1, :state, :zip_code])
    |> unique_constraint(:ein)
  end
end
