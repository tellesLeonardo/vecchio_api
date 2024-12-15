defmodule VecchioApi.KeyValueStoresTest do
  use ExUnit.Case, async: true
  alias VecchioApi.Database.Context.KeyValueStores

  @collection "key_value_store"

  # Antes de cada teste, criamos uma nova conexão com o banco de dados de teste
  setup do
    conn = :mongo

    # Limpar a coleção antes de cada teste para garantir testes isolados
    Mongo.delete_many(conn, @collection, %{})
    :ok
  end

  test "insert/1 insere um novo documento com sucesso" do
    key_value = %{key: "test_key", value: "test_value", client: "test_client", in_transaction: true}

    # Tenta inserir o documento
    assert {:ok, %{id: _id}} = KeyValueStores.insert(key_value)

    # Verifica se o documento foi inserido
    assert {:ok, %{"key" => "test_key", "value" => "test_value"}} = KeyValueStores.find_by_key("test_key")
  end

  test "find_by_key/1 retorna o documento correto" do
    key_value = %{key: "test_key", value: "test_value", client: "test_client", in_transaction: true}

    # Inserindo o documento
    {:ok, %{id: _id}} = KeyValueStores.insert(key_value)

    # Verifica se o documento pode ser encontrado pela chave
    assert {:ok, %{"key" => "test_key", "value" => "test_value"}} = KeyValueStores.find_by_key("test_key")
  end

  test "update_by_key/2 atualiza um documento corretamente" do
    key_value = %{key: "test_key", value: "test_value", client: "test_client", in_transaction: true}

    # Inserindo o documento
    {:ok, %{id: _id}} = KeyValueStores.insert(key_value)

    # Atualizando o documento
    updated_value = %{value: "updated_value"}
    assert {:ok, :updated} = KeyValueStores.update_by_key("test_key", updated_value)

    # Verificando se o documento foi atualizado
    assert {:ok, %{"key" => "test_key", "value" => "updated_value"}} = KeyValueStores.find_by_key("test_key")
  end

  test "delete_by_key/1 deleta um documento corretamente" do
    key_value = %{key: "test_key", value: "test_value", client: "test_client", in_transaction: true}

    # Inserindo o documento
    {:ok, %{id: _id}} = KeyValueStores.insert(key_value)

    # Deletando o documento
    assert {:ok, :deleted} = KeyValueStores.delete_by_key("test_key")

    # Verificando se o documento foi deletado
    assert {:error, :not_found} = KeyValueStores.find_by_key("test_key")
  end

  test "list_all/0 retorna todos os documentos" do
    # Inserindo dois documentos
    key_value1 = %{key: "key1", value: "value1", client: "client1", in_transaction: true}
    key_value2 = %{key: "key2", value: "value2", client: "client2", in_transaction: false}

    {:ok, %{id: _id1}} = KeyValueStores.insert(key_value1)
    {:ok, %{id: _id2}} = KeyValueStores.insert(key_value2)

    # Verificando se todos os documentos estão presentes
    assert length(KeyValueStores.list_all()) == 2
  end
end
