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
    test "insere um novo documento corretamente" do
      document = %{key: "idade", value: 30}

      assert {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Verificando que o documento foi inserido corretamente
      assert {:ok, result} = KeyValueStores.find_by_key("idade")
      assert result["data"]["idade"] == 30
    end
  end

  describe "find_by_key/1" do
    test "retorna um documento baseado na chave" do
      # Insere um documento
      document = %{key: "idade", value: 25}
      {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Realiza a busca
      assert {:ok, result} = KeyValueStores.find_by_key("idade")
      assert result["data"]["idade"] == 25
    end

    test "retorna erro quando a chave não é encontrada" do
      assert {:error, :not_found} = KeyValueStores.find_by_key("idade")
    end
  end

  describe "update_by_key/2" do
    test "atualiza o valor corretamente" do
      # Insere um documento
      document = %{key: "idade", value: 40}
      {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Atualiza o documento
      updates = %{"data.idade" => 45}
      assert {:ok, :updated} = KeyValueStores.update_by_key("idade", updates)

      # Verifica se o valor foi atualizado
      assert {:ok, result} = KeyValueStores.find_by_key("idade")
      assert result["data"]["idade"] == 45
    end

    test "retorna erro quando a chave não existe" do
      updates = %{"data.idade" => 30}
      assert {:error, :not_found} = KeyValueStores.update_by_key("idade", updates)
    end
  end

  describe "delete_by_key/1" do
    test "deleta o documento corretamente" do
      # Insere um documento
      document = %{key: "idade", value: 50}
      {:ok, %{id: _id}} = KeyValueStores.insert(document)

      # Deleta o documento
      assert {:ok, :deleted} = KeyValueStores.delete_by_key("idade")

      # Verifica se o documento foi deletado
      assert {:error, :not_found} = KeyValueStores.find_by_key("idade")
    end

    test "retorna erro quando a chave não existe" do
      assert {:error, :not_found} = KeyValueStores.delete_by_key("idade")
    end
  end

  describe "list_all/0" do
    test "retorna todos os documentos" do
      # Insere alguns documentos
      document1 = %{key: "idade", value: 60}
      document2 = %{key: "nome", value: "João"}
      {:ok, _} = KeyValueStores.insert(document1)
      {:ok, _} = KeyValueStores.insert(document2)

      # Verifica se os documentos foram inseridos
      documents = KeyValueStores.list_all()
      assert length(documents) == 2
      assert Enum.any?(documents, fn doc -> doc["data"]["idade"] == 60 end)
      assert Enum.any?(documents, fn doc -> doc["data"]["nome"] == "João" end)
    end
  end
end
