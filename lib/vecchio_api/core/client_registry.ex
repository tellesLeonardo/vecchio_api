defmodule VecchioApi.Core.ClientRegistry do
  @moduledoc """
  Encapsula operações para o Registry, como registro, busca e interação com processos de usuários.
  """

  # Define o nome do Registry
  @registry_name VecchioApi.Registry

  @doc """
  Registra um processo de usuário no Registry.
  """
  def register_user(client_name) do
    case Registry.register(@registry_name, client_name, nil) do
      {:ok, _pid} -> :ok
      {:error, {:already_registered, _pid}} -> {:error, :already_registered}
    end
  end

  @doc """
  Busca o PID de um usuário registrado no Registry.
  """
  def whereis_user(client_name) do
    case Registry.lookup(@registry_name, client_name) do
      [{pid, _value}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  Remove um registro (apenas simbólico, o processo encerra automaticamente).
  """
  def unregister_user(client_name) do
    Registry.unregister(@registry_name, client_name)
  end
end
