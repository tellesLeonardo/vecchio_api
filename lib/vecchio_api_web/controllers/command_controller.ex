defmodule VecchioApiWeb.CommandController do
  use VecchioApiWeb, :controller

  alias VecchioApi.Command.Handler
  alias VecchioApi.Core.ClientManger

  def command(conn, _data) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    response =
      case Handler.handle_command(body) do
        {:error, error_message} -> error_message
        data -> ClientManger.execute(data, conn.assigns.client_name)
      end

    conn
    |> put_status(:ok)
    |> text(response)
  end
end
