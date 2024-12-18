defmodule VecchioApi.Core.ClientManger do
  alias VecchioApi.Command.Handler
  alias VecchioApi.Core.UserSupervisor
  alias VecchioApi.Core.ClientRegistry

  def execute(%Handler{} = data, client_name) do
    case ClientRegistry.whereis_user(client_name) do
      {:ok, pid} ->
        pid

      {:error, :not_found} ->
        {:ok, pid} = UserSupervisor.start_user(client_name)
        pid
    end
    |> GenServer.call(data)
  end
end
