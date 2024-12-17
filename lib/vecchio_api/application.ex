defmodule VecchioApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VecchioApiWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:vecchio_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VecchioApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VecchioApi.Finch},
      # Start a worker by calling: VecchioApi.Worker.start_link(arg)
      VecchioApi.Repo,
      # Start to serve requests, typically the last entry
      # my supervisor
      VecchioApi.Core.UserSupervisor,
      # my registry
      {Registry, keys: :unique, name: VecchioApi.Registry},
      VecchioApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VecchioApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VecchioApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
