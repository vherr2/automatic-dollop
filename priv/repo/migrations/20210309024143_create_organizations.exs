defmodule Npf.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :ein, :integer
      add :name_line_1, :text
      add :name_line_2, :text
      add :address_line_1, :text
      add :address_line_2, :text
      add :city, :text
      add :state, :text
      add :zip_code, :text

      timestamps()
    end

    create unique_index(:organizations, [:ein])
  end
end
