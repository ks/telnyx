defmodule Telnyx.Repo.Migrations.Init do
  use Ecto.Migration
  
  def change do

    create table(:products) do
      add :external_product_id, :integer
      add :price, :integer
      add :product_name, :string
      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:external_product_id], name: :external_product_id_index)
    
    create table(:past_price_records) do
      add :product_id, :integer,
        [references(:products, column: :external_product_id, type: :integer)]
      add :price, :integer
      add :percentage_change, :float
      timestamps(type: :utc_datetime)
    end
    
  end
end
