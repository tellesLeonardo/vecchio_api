defmodule VecchioApi.Database.Context.KeyValueStoresTest do
  use ExUnit.Case
  alias VecchioApi.Database.Context.KeyValueStores
  alias Mongo

  @moduletag :capture_log

  @collection "key_value_store"
  @conn :mongo

  setup do
    # Preparação para limpar a coleção antes de cada teste
    Mongo.delete_many(@conn, @collection, %{})
    :ok
  end

  describe "insert/1" do
    test "inserts a new document correctly" do
      document = %{key: "idade", value: 30}

      assert {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Verifying that the document was inserted correctly
      assert {:ok, result} = KeyValueStores.find_by_key("idade")
      assert result["data"]["idade"] == 30
    end
  end

  describe "find_by_key/1" do
    test "returns a document based on the key" do
      # Inserts a document
      document = %{key: "idade", value: 25}
      {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Performs the search
      assert {:ok, result} = KeyValueStores.find_by_key("idade")
      assert result["data"]["idade"] == 25
    end

    test "returns an error when the key is not found" do
      assert {:error, :not_found} = KeyValueStores.find_by_key("idade")
    end
  end

  describe "update_by_key/2" do
    test "updates the value correctly" do
      # Inserts a document
      document = %{key: "idade", value: 40}
      {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Updates the document
      updates = %{"data.idade" => 45}
      assert {:ok, :updated} = KeyValueStores.update_by_key("idade", updates)

      # Verifies if the value was updated
      assert {:ok, result} = KeyValueStores.find_by_key("idade")
      assert result["data"]["idade"] == 45
    end

    test "returns the insert when the key does not exist due to upsert" do
      updates = %{"data.idade" => 30}
      assert {:ok, :updated} = KeyValueStores.update_by_key("idade", updates)
    end
  end

  describe "delete_by_key/1" do
    test "deletes the document correctly" do
      # Inserts a document
      document = %{key: "idade", value: 50}
      {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Deletes the document
      assert {:ok, :deleted} = KeyValueStores.delete_by_key("idade")

      # Verifies if the document was deleted
      assert {:error, :not_found} = KeyValueStores.find_by_key("idade")
    end

    test "returns an error when the key does not exist" do
      assert {:error, :not_found} = KeyValueStores.delete_by_key("idade")
    end
  end

  describe "list_all/0" do
    test "returns all documents" do
      # Inserts some documents
      document1 = %{key: "idade", value: 60}
      document2 = %{key: "nome", value: "João"}
      {:ok, _} = KeyValueStores.insert(document1)
      {:ok, _} = KeyValueStores.insert(document2)

      # Verifies if the documents were inserted
      documents = KeyValueStores.list_all()
      assert length(documents) == 2
      assert Enum.any?(documents, fn doc -> doc["data"]["idade"] == 60 end)
      assert Enum.any?(documents, fn doc -> doc["data"]["nome"] == "João" end)
    end
  end
end
