defmodule Telnyx.BasicTest do

  use Telnyx.DataCase

  alias Telnyx.Repo
  alias TelnyxDb.Product
  alias TelnyxDb.PriceRecord

  import Telnyx, only: [track_product: 1, get_product: 1, last_price_record: 1]
  
  
  test "ignore discontinued product if we don't track it" do
    nil = get_product(1)
    {:ok, :discontinued} = track_product(product_def(1, "", 5.3, true))
    nil = get_product(1)
  end

  test "ignore product with invalid price" do
    {:error, :invalid_price} = track_product(product_def(1000, "", "sss"))
    nil = get_product(1000)
  end
  
  test "ignore invalid product" do
    {:error, :invalid_product} = track_product(%{bogus: true})
  end

  test "add new product" do
    nil = get_product(1)
    {:ok, :new_product} = track_product(product_def(1, "product 1", 10))
    %Product{external_product_id: 1,
             price: 1000,
             product_name: "product 1",
             past_price_records: [%PriceRecord{product_id: 1,
                                               price: 1000,
                                               percentage_change: nil}]} =
      get_product(1) |> Repo.preload(:past_price_records)
    %PriceRecord{product_id: 1, price: 1000} = last_price_record(1)
  end

  test "ignore product name change" do
    nil = get_product(1)
    {:ok, :new_product} = track_product(product_def(1, "product 1", 10))
    %Product{} = product1 = get_product(1) |> Repo.preload(:past_price_records)
    {:ok, {:product_name_mismatch, "product 1"}} = track_product(product_def(1, "bogus", 10))
    %Product{} = product2 = get_product(1) |> Repo.preload(:past_price_records)
    true = product1 == product2
  end
  
  test "ignore no price change" do
    nil = get_product(1)
    {:ok, :new_product} = track_product(product_def(1, "product 1", 10))
    %Product{} = product1 = get_product(1) |> Repo.preload(:past_price_records)
    {:ok, :no_price_change} = track_product(product_def(1, "product 1", 10))
    %Product{} = product2 = get_product(1) |> Repo.preload(:past_price_records)
    true = product1 == product2
  end

  test "price change" do
    nil = get_product(1)
    {:ok, :new_product} = track_product(product_def(1, "product 1", 10))
    {:ok, {:price_change, 50.0}} = track_product(product_def(1, "product 1", 15))
    %Product{external_product_id: 1,
             price: 1500,
             product_name: "product 1",
             past_price_records: [%PriceRecord{}, %PriceRecord{}]} =
      get_product(1) |> Repo.preload(:past_price_records)
    %PriceRecord{product_id: 1, price: 1500} = last_price_record(1)
  end

  test "price change of discontinued product" do
    nil = get_product(1)
    {:ok, :new_product} = track_product(product_def(1, "product 1", 10))
    {:ok, {:price_change, 50.0}} = track_product(product_def(1, "product 1", 15, true))
    %Product{external_product_id: 1,
             price: 1500,
             product_name: "product 1",
             past_price_records: [%PriceRecord{}, %PriceRecord{}]} =
      get_product(1) |> Repo.preload(:past_price_records)
    %PriceRecord{product_id: 1, price: 1500} = last_price_record(1)
  end
  
end
