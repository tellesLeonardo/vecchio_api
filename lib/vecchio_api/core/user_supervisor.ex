defmodule VecchioApi.Core.UserSupervisor do
  use DynamicSupervisor

  alias VecchioApi.Core.UserGenServer

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_user(data) do
    child_spec = {UserGenServer, data}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def terminate_child(pid) do
    if Process.alive?(pid) do
      IO.puts("Terminando o processo #{inspect(pid)}")
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    else
      IO.puts("Processo já terminado.")
    end
  end
end
