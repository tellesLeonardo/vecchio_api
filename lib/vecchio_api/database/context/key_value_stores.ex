defmodule VecchioApi.Database.Context.KeyValueStores do
  @moduledoc """
  CRUD para a coleção `key_value_store`.
  """
  alias Mongo
  @collection "key_value_store"
  @conn :mongo

  @doc """
  Insere um novo documento na coleção `key_value_store`.
  """
  def insert(%{
        key: key,
        value: value,
        client: client,
        in_transaction: in_transaction
      }) do
    document = %{
      key: key,
      value: value,
      client: client,
      in_transaction: in_transaction
    }

    case Mongo.insert_one(@conn, @collection, document) do
      {:ok, %Mongo.InsertOneResult{inserted_id: id}} ->
        {:ok, %{id: BSON.ObjectId.encode!(id)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Busca um documento pelo campo `key`.
  """
  def find_by_key(key) do
    query = %{key: key}

    case Mongo.find_one(@conn, @collection, query) do
      nil -> {:error, :not_found}
      document -> {:ok, document}
    end
  end

  @doc """
  Atualiza um documento com base no campo `key`.
  """
  def update_by_key(key, updates) do
    filter = %{key: key}
    update = %{"$set" => updates}

    case Mongo.update_one(@conn, @collection, filter, update) do
      {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
        {:error, :not_found}

      {:ok, %Mongo.UpdateResult{}} ->
        {:ok, :updated}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Remove um documento pelo campo `key`.
  """
  def delete_by_key(key) do
    filter = %{key: key}

    case Mongo.delete_one(@conn, @collection, filter) do
      {:ok, %Mongo.DeleteResult{deleted_count: 0}} ->
        {:error, :not_found}

      {:ok, %Mongo.DeleteResult{}} ->
        {:ok, :deleted}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Retorna todos os documentos da coleção `key_value_store`.
  """
  def list_all() do
    Mongo.find(@conn, @collection, %{})
    |> Enum.to_list()
  end
end
