defmodule Telnyx do

  require Logger
  require Ecto.Query

  alias Ecto.Query
  alias Ecto.Changeset
  alias Telnyx.Repo
  alias TelnyxDb.Product
  alias TelnyxDb.PriceRecord


  def track_product(%{id: ext_id,
                       name: name,
                       price: ("$" <> price_str),
                       discontinued: discontinued?} = product_desc)
  when is_integer(ext_id) and is_binary(name) and is_boolean(discontinued?) do
    case Float.parse(price_str) do
      {price_usd, ""} ->
        desc = %{product_desc | price: price_usd * 100 |> trunc}
        {:ok, status} = fn -> update_db(get_product(ext_id), desc) end |> Repo.transaction
        case status do
          :no_price_change ->
            Logger.info "no price change for product '#{name}' (ID = #{ext_id})"
          {:product_name_mismatch, orig_name} ->
            Logger.info "product name mismatch (ID = #{ext_id}): '#{orig_name}' vs '#{name}'"
          {:price_change, change} ->
            Logger.info "product '#{name}' (ID = #{ext_id}) changed price #{change}%"
          :new_product ->
            Logger.info "new product '#{name}' (ID = #{ext_id}) priced at $#{price_usd}"
          :discontinued ->
            Logger.info "ignoring already discontinued product '#{name}' (ID = #{ext_id})"
        end
        {:ok, status}
      _ ->
        Logger.info "ignoring invalid price (#{price_str}) for '#{name}' (ID = #{ext_id})"
        {:error, :invalid_price}
    end
  end

  def track_product(_invalid_product) do
    Logger.info "ignoring invalid product description"
    {:error, :invalid_product}
  end

  
  defp update_db(%Product{product_name: name, price: cents}, %{name: name, price: cents}) do
    :no_price_change
  end
  defp update_db(%Product{product_name: orig_name}, %{name: name}) when name != orig_name do
    {:product_name_mismatch, orig_name}
  end
  defp update_db(%Product{product_name: name, price: prev_cents} = product,
                  %{name: name, price: cents}) do
    change = ((cents / prev_cents) * 100) - 100
    last_price = %{price: cents, percentage_change: change}
    Repo.update!(product |> Changeset.change(%{price: cents}))
    Repo.insert!(Ecto.build_assoc(product, :past_price_records, last_price))
    {:price_change, change}
  end
  defp update_db(nil, %{id: ext_id, name: name, price: cents, discontinued: false}) do
    Repo.insert!(%Product{external_product_id: ext_id,
                          price: cents,
                          product_name: name,
                          past_price_records: [%PriceRecord{price: cents}]})
    :new_product
  end
  defp update_db(nil, %{discontinued: true}) do
    :discontinued
  end
  
  
  def get_product(ext_id) do
    Product |> Repo.get_by(external_product_id: ext_id)
  end

  def last_price_record(ext_id) do
    PriceRecord |> Query.where(product_id: ^ext_id) |> Query.last(:inserted_at) |> Repo.one 
  end
 
  # def tt(ext_id, price, opts \\ %{discontinued: false, name: ""}) do
  #   track_product(%{id: ext_id,
  #                   name: opts.name,
  #                   price: "$#{price}",
  #                   discontinued: opts.discontinued})
  # end
  
end
