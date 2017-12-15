defmodule TelnyxDb do

  defmodule Product do
    use Ecto.Schema

    @timestamps_opts [type: :utc_datetime]
  
    schema "products" do
      field :external_product_id, :integer
      field :price, :integer
      field :product_name, :string
      timestamps()
      
      has_many :past_price_records, TelnyxDb.PriceRecord,
        references: :external_product_id,
        foreign_key: :product_id,
        on_delete: :delete_all
    end
  end

  defmodule PriceRecord do
    use Ecto.Schema

    @timestamps_opts [type: :utc_datetime]
  
    schema "past_price_records" do
      field :product_id, :integer
      field :price, :integer
      field :percentage_change, :float
      timestamps()
      
      belongs_to :products, Product,
        define_field: false,
        references: :product_id,
        foreign_key: :external_product_id
    end
  end

end
