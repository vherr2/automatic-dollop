defmodule Npf.Repo.Migrations.CreateFiling do
  use Ecto.Migration

  def change do
    create table(:filings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :filer_id, references(:organizations, type: :uuid, on_delete: :nothing)

      add :tax_period_begin_date, :date
      add :tax_period_end_date, :date

      timestamps()
    end

    create unique_index(:filings, [:filer_id, :tax_period_begin_date, :tax_period_end_date])
  end
end
