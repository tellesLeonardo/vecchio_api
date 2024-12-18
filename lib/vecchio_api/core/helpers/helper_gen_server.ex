defmodule VecchioApi.Core.Helpers.HelperGenServer do
  # Aliases necessários
  alias VecchioApi.Command.Handler
  alias VecchioApi.Database.Context.KeyValueStores
  require Logger

  # Função que processa o comando :set dentro de uma transação
  @doc """
  Processa o comando :set quando a transação está ativa.
  Atualiza o estado da transação e retorna o valor antigo e novo.

  ## Parâmetros
  - map: O comando do tipo `Handler` com a chave e o valor a serem definidos.
  - state: O estado atual do GenServer.

  ## Retorno
  - Tuple contendo o valor anterior e o valor atual como string, além do novo estado atualizado.
  """
  def process_set(%Handler{key: key, value: value} = map, %{transaction: true} = state) do
    old_value =
      find_latest_value(key, state.commands_in_transaction) || find_key_in_db(key) || "NIL"

    # Atualizando a lista de comandos da transação e os valores modificados
    updated_commands_in_transaction = state.commands_in_transaction ++ [map]
    updated_modified_keys = Map.put_new_lazy(state.modified_keys, map.key, fn -> old_value end)

    updated_state = %{
      state
      | commands_in_transaction: updated_commands_in_transaction,
        modified_keys: updated_modified_keys
    }

    Logger.debug(
      "Comando :set para a chave #{key} com valor antigo #{old_value} e valor novo #{value}"
    )

    {"#{old_value} #{value}", updated_state}
  end

  # Função que processa o comando :set fora de uma transação
  @doc """
  Processa o comando :set quando a transação não está ativa,
  realizando a atualização diretamente no banco de dados.

  ## Parâmetros
  - map: O comando do tipo `Handler` com a chave e o valor a serem definidos.
  - state: O estado atual do GenServer.

  ## Retorno
  - Tuple contendo o valor antigo e o novo, além do estado atual.
  """
  def process_set(%Handler{key: key, value: value}, %{transaction: false} = state) do
    old_value = find_key_in_db(key) || "NIL"

    # Atualizando o valor no banco de dados
    KeyValueStores.update_by_key(key, %{"data" => %{key => value}})

    Logger.info(
      "Comando :set fora de transação: chave #{key} com valor antigo #{old_value} e valor novo #{value}"
    )

    {"#{old_value} #{value}", state}
  end

  # Função que processa o comando :get dentro de uma transação
  @doc """
  Processa o comando :get dentro de uma transação.
  Retorna o valor mais recente encontrado na transação ou no banco de dados.

  ## Parâmetros
  - map: O comando do tipo `Handler` com a chave a ser consultada.
  - state: O estado atual do GenServer.

  ## Retorno
  - Tuple contendo o valor encontrado e o estado atual.
  """
  def process_get(%Handler{key: key}, %{transaction: true} = state) do
    value = find_latest_value(key, state.commands_in_transaction) || find_key_in_db(key) || "NIL"

    Logger.debug(
      "Comando :get dentro de transação para a chave #{key}, valor encontrado: #{value}"
    )

    {value, state}
  end

  # Função que processa o comando :get fora de uma transação
  @doc """
  Processa o comando :get fora de uma transação.
  Retorna o valor encontrado diretamente no banco de dados.

  ## Parâmetros
  - map: O comando do tipo `Handler` com a chave a ser consultada.
  - state: O estado atual do GenServer.

  ## Retorno
  - Tuple contendo o valor encontrado e o estado atual.
  """
  def process_get(%Handler{key: key}, %{transaction: false} = state) do
    value = find_key_in_db(key) || "NIL"

    Logger.debug("Comando :get fora de transação para a chave #{key}, valor encontrado: #{value}")

    {value, state}
  end

  # Função que verifica inconsistências nos dados modificados
  @doc """
  Verifica se houve inconsistências entre os valores modificados na transação e os valores no banco de dados.

  ## Parâmetros
  - modified_keys: O mapa de chaves modificadas e seus valores originais.

  ## Retorno
  - Lista de chaves que apresentaram inconsistências.
  """
  def check_inconsistencies(modified_keys) do
    inconsistencies =
      Enum.filter(modified_keys, fn {key, original_value} ->
        current_value = find_key_in_db(key)
        current_value != original_value
      end)

    Logger.debug("Inconsistências encontradas: #{inspect(inconsistencies)}")

    inconsistencies
  end

  # Função que aplica os comandos de transação no banco de dados
  @doc """
  Aplica os comandos da transação no banco de dados.

  ## Parâmetros
  - commands_in_transaction: Lista de comandos de transação a serem aplicados.

  ## Retorno
  - Nenhum retorno.
  """
  def apply_transaction_commands(commands_in_transaction) do
    Enum.each(commands_in_transaction, fn cmd ->
      KeyValueStores.update_by_key(cmd.key, %{"data" => %{cmd.key => cmd.value}})
      Logger.info("Aplicando comando :set para a chave #{cmd.key} com valor #{cmd.value}")
    end)
  end

  # Função que formata e retorna inconsistências encontradas
  @doc """
  Formata uma mensagem de erro para inconsistências encontradas durante a transação.

  ## Parâmetros
  - inconsistencies: Lista de inconsistências encontradas.

  ## Retorno
  - String formatada com as inconsistências.
  """
  def format_inconsistencies(inconsistencies) do
    erros =
      inconsistencies
      |> Enum.map(&elem(&1, 0))
      |> Enum.join(",")

    Logger.error("Falha de atomicidade detectada: #{erros}")

    "Atomicity failure (#{erros})"
  end

  # Função privada que encontra o valor mais recente de uma chave na transação
  defp find_latest_value(key, commands_in_transaction) do
    commands_in_transaction
    |> Enum.reverse()
    |> Enum.find(fn cmd -> cmd.code == :set and cmd.key == key end)
    |> case do
      nil -> nil
      %Handler{value: value} -> value
    end
  end

  # Função privada que encontra o valor de uma chave no banco de dados
  defp find_key_in_db(key) do
    case KeyValueStores.find_by_key(key) do
      {:ok, %{"data" => data}} -> Map.get(data, key)
      _ -> nil
    end
  end
end
