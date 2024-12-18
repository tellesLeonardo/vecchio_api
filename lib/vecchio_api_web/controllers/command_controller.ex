defmodule VecchioApiWeb.CommandController do
  use VecchioApiWeb, :controller

  alias VecchioApi.Command.Handler
  alias VecchioApi.Core.ClientManger

  def command(conn, _data) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    Logger.info(
      "#{__MODULE__}: Iniciando o processo de salvamento de dados client #{conn.assigns.client_name}"
    )

    response =
      case Handler.handle_command(body) do
        {:error, error_message} ->
          Logger.warning(
            "#{__MODULE__}: O comando passado pelo client #{conn.assigns.client_name} não é valido #{body} erro: #{error_message}"
          )

          error_message

        data ->
          Logger.info(
            "#{__MODULE__}: Iniciando a criação do Gen server do client #{conn.assigns.client_name} com dados #{inspect(data)}"
          )

          ClientManger.execute(data, conn.assigns.client_name)
      end

    conn
    |> put_status(:ok)
    |> text(response)
  end
end
