defmodule VecchioApi.Schemas.KeyValueStore do
  use Mongo.Collection
  alias __MODULE__

  collection ("key_value_store") do
    attribute(:id, :string, derived: true)
    attribute(:key, :string)
    attribute(:value, :string)
    attribute(:client, :string)
    attribute(:in_transaction, :boolean)

    after_load(&KeyValueStore.after_load/1)
    before_dump(&KeyValueStore.before_dump/1)

  end

  def after_load(%__MODULE__{_id: id} = data) do
    %__MODULE__{data | id: BSON.ObjectId.encode!(id)}
  end

  def before_dump(data) do
    %__MODULE__{data | id: nil}
  end

  def new(key, value, client, in_transaction) do
    new()
    |> Map.put(:key, key)
    |> Map.put(:value, value)
    |> Map.put(:client, client)
    |> Map.put(:in_transaction, in_transaction)
    |> after_load()
  end
end
