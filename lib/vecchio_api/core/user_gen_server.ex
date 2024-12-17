defmodule VecchioApi.Core.UserGenServer do
  use GenServer

  alias VecchioApi.Command.Handler
  alias VecchioApi.Core.ClientRegistry
  alias VecchioApi.Core.UserSupervisor

  @timeout_duration 300_000

  def start_link(client_name) do
    GenServer.start_link(
      __MODULE__,
      %{client_name: client_name, commands_in_transaction: []},
      name: via_tuple(client_name)
    )
  end

  defp via_tuple(client_name), do: {:via, Registry, {VecchioApi.Registry, client_name}}

  def init(state) do
    IO.puts("#{__MODULE__} - enter init func")
    ClientRegistry.register_user(state.client_name)

    {:ok, state}
  end

  def handle_call(%Handler{code: :set}, _from, state) do
    # TODO implement rules
    # Reinicia timeout
    IO.puts("#{__MODULE__} dentro do set")

    schedule_timeout()

    {:reply, :set, state}
  end

  def handle_call(%Handler{code: :get}, _from, state) do
    # TODO implement rules
    # Reinicia timeout
    schedule_timeout()
    IO.puts("#{__MODULE__} dentro do GET")

    {:reply, :get, state}
  end

  def handle_call(%Handler{code: :begin}, _from, state) do
    # TODO implement rules
    # Reinicia timeout
    schedule_timeout()

    {:reply, :begin, state}
  end

  def handle_call(%Handler{code: :rollback}, _from, state) do
    # TODO implement rules
    # Reinicia timeout
    schedule_timeout()

    {:reply, :rollback, state}
  end

  def handle_call(%Handler{code: :commit}, _from, state) do
    # TODO implement rules
    # Reinicia timeout
    schedule_timeout()

    {:reply, :commit, state}
  end

  def handle_info(:timeout, state) do
    IO.puts("Encerrando GenServer do usuário #{state.client_name} por inatividade.")
    ClientRegistry.unregister_user(state.client_name)

    UserSupervisor.terminate_child(self())

    {:stop, :normal, state}
  end

  defp schedule_timeout do
    Process.send_after(self(), :timeout, @timeout_duration)
  end
end

# TODO lê a documentação fazer a parte do get e set depois o testes

# TODO lê a documentação fazer a parte do begin, roolbak e commit
