defmodule TelnyxOmega do

  def get_products() do
    kvs = Application.get_env(:telnyx, :omega_pricing)
    host = kvs |> Keyword.get(:host)
    port = kvs |> Keyword.get(:port)
    api_user = kvs |> Keyword.get(:api_user)
    api_key = kvs |> Keyword.get(:api_key)

    # Erlang's builtin http client is a bit low level
    headers = [{'Authorization',
                ("Basic " <> Base.encode64("#{api_user}:#{api_key}")) |> to_charlist}]
    url = "http://#{host}:#{port}/pricing/records.json" |> to_charlist
    
    case :httpc.request(:get, {url, headers}, [], []) do
      {:ok, {{_, 200, 'OK'}, _resp_headers, records_json}} ->
        {:ok, records_json |> Poison.decode!}
      _ ->
        {:error, :cant_fetch}
    end
  end

  def update_db() do
    case get_products() do
      {:ok, %{"productRecords" => products}} ->
        for %{"id" => id,
              "name" => name,
              "price" => price,
              "discontinued" => discontinued} <- products do
            Telnyx.track_product(%{id: id, name: name, price: price, discontinued: discontinued})
        end
      {:ok, _} ->
        {:error, :invalid_products_json}
      {:error, :cant_fetch} ->
        {:error, :cant_fetch}
    end
  end
  
end
