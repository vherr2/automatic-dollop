defmodule Npf.Repo.Migrations.CreateAwards do
  use Ecto.Migration

  def change do
    create table(:awards, primary_key: false) do
      add :filing_id, references(:filings, type: :uuid, on_delete: :nothing), primary_key: true

      add :receiver_id, references(:organizations, type: :uuid, on_delete: :nothing),
        primary_key: true

      add :amount, :integer
      add :purpose, :text

      timestamps()
    end
  end
end
