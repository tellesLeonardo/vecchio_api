defmodule VecchioApi.Core.UserGenServer do
  use GenServer

  alias VecchioApi.Command.Handler
  alias VecchioApi.Core.{ClientRegistry, UserSupervisor}
  alias VecchioApi.Core.Helpers.HelperGenServer

  require Logger

  @timeout_duration 600_000

  ## API
  @doc """
  Inicia um novo GenServer para um cliente com o nome especificado.
  Registra o cliente no `ClientRegistry`.

  ## Parâmetros
    - `client_name`: Nome do cliente para ser registrado.

  ## Retorno
    - `{:ok, pid}`: Retorna o pid do GenServer iniciado.
  """
  def start_link(client_name) do
    GenServer.start_link(
      __MODULE__,
      %{
        client_name: client_name,
        commands_in_transaction: [],
        transaction: false,
        modified_keys: %{}
      },
      name: via_tuple(client_name)
    )
  end

  ## Callbacks

  @doc """
  Inicializa o estado do GenServer e registra o cliente no `ClientRegistry`.

  ## Retorno
    - `{:ok, state}`: Retorna o estado inicial após o registro.
  """
  def init(state) do
    Logger.info("#{__MODULE__}: Iniciando GenServer para o cliente #{state.client_name}")

    ClientRegistry.register_user(state.client_name)
    {:ok, state}
  end

  @doc """
  Processa uma requisição de `set` e altera o valor de uma chave no estado.

  ## Parâmetros
    - `map`: O comando que contém a chave e o valor a ser setado.

  ## Retorno
    - `{:reply, response, new_state}`: Resposta da operação e o novo estado.
  """
  def handle_call(%Handler{code: :set} = map, _from, state) do
    Logger.info(
      "#{__MODULE__}: Processando comando :set para a chave #{map.key} com valor #{map.value}"
    )

    {response, state} = HelperGenServer.process_set(map, state)
    schedule_timeout()
    {:reply, response, state}
  end

  @doc """
  Processa uma requisição de `get` e retorna o valor de uma chave.

  ## Parâmetros
    - `map`: O comando que contém a chave a ser recuperada.

  ## Retorno
    - `{:reply, response, state}`: Resposta da operação e o estado atual.
  """
  def handle_call(%Handler{code: :get} = map, _from, state) do
    Logger.info("#{__MODULE__}: Processando comando :get para a chave #{map.key}")
    {response, state} = HelperGenServer.process_get(map, state)
    schedule_timeout()
    {:reply, response, state}
  end

  @doc """
  Inicia uma transação para o cliente, permitindo a modificação de chaves.

  ## Retorno
    - `{:reply, response, new_state}`: Retorna a resposta do início da transação e o novo estado.
  """
  def handle_call(%Handler{code: :begin}, _from, state) do
    Logger.info("#{__MODULE__}: Iniciando transação para o cliente #{state.client_name}")

    {response, state} =
      if state.transaction do
        {"Already in transaction", state}
      else
        {:ok, Map.put(state, :transaction, true)}
      end

    schedule_timeout()
    {:reply, response, state}
  end

  @doc """
  Realiza o rollback de uma transação, revertendo qualquer alteração.

  ## Retorno
    - `{:reply, response, new_state}`: Retorna a resposta do rollback e o estado resetado.
  """
  def handle_call(%Handler{code: :rollback}, _from, state) do
    Logger.info("#{__MODULE__}: Revertendo transação para o cliente #{state.client_name}")

    response =
      if Enum.empty?(state.commands_in_transaction) do
        "Transaction level 0"
      else
        :ok
      end

    new_state = reset_state(state)
    schedule_timeout()
    {:reply, response, new_state}
  end

  @doc """
  Comita as alterações feitas durante a transação, submetendo as chaves modificadas.

  ## Retorno
    - `{:reply, response, new_state}`: Resposta sobre o sucesso ou falha no commit e o estado resetado.
  """
  def handle_call(%Handler{code: :commit}, _from, state) do
    Logger.info("#{__MODULE__}: Comitando transação para o cliente #{state.client_name}")
    inconsistencies = HelperGenServer.check_inconsistencies(state.modified_keys)

    response =
      if inconsistencies == [] do
        HelperGenServer.apply_transaction_commands(state.commands_in_transaction)

        Logger.info(
          "#{__MODULE__}: Transação comitada com sucesso para o cliente #{state.client_name}"
        )

        :ok
      else
        Logger.warning(
          "#{__MODULE__}: Não foi possivel terminar o processo de salvmento da transação por já terem alterado a key | client: #{state.client_name}"
        )

        HelperGenServer.format_inconsistencies(inconsistencies)
      end

    state = reset_state(state)
    schedule_timeout()
    {:reply, response, state}
  end

  @doc """
  Lida com o timeout, encerrando o GenServer após o período de inatividade.

  ## Retorno
    - `{:stop, :normal, state}`: Encerra o GenServer.
  """
  def handle_info(:timeout, state) do
    Logger.info(
      "#{__MODULE__}: Encerrando GenServer do usuário #{state.client_name} por inatividade."
    )

    ClientRegistry.unregister_user(state.client_name)
    UserSupervisor.terminate_child(self())
    {:stop, :normal, state}
  end

  ## Helper Functions

  @doc """
  Reseta o estado do GenServer, limpando transações pendentes e chaves modificadas.

  ## Retorno
    - `new_state`: O novo estado resetado.
  """
  defp reset_state(state) do
    Logger.info("#{__MODULE__}: Resetando estado para o cliente #{state.client_name}")

    %{
      state
      | commands_in_transaction: [],
        transaction: false,
        modified_keys: %{}
    }
  end

  @doc """
  Agenda o timeout para o GenServer, para que ele seja encerrado após o período de inatividade.

  ## Retorno
    - Nenhum. Apenas agendamos o evento de timeout.
  """
  defp schedule_timeout do
    Process.send_after(self(), :timeout, @timeout_duration)
  end

  @doc """
  Retorna a tupla de registro para o cliente com o nome fornecido, para registro no `Registry`.

  ## Parâmetros
    - `client_name`: Nome do cliente.

  ## Retorno
    - Tupla do tipo `{:via, Registry, {VecchioApi.Registry, client_name}}`
  """
  defp via_tuple(client_name), do: {:via, Registry, {VecchioApi.Registry, client_name}}
end
