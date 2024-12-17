defmodule VecchioApiWeb.CommandController do
  use VecchioApiWeb, :controller

  alias VecchioApi.Command.Handler
  alias VecchioApi.Core.ClientManger

  def command(conn, _data) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    IO.inspect(body, label: "#{__MODULE__}")

    case Handler.handle_command(body) do
      {:error, _} = data -> IO.inspect(data)
      data -> ClientManger.execute(data, conn.assigns.client_name)
    end

    conn
    |> put_status(:ok)
    |> json(%{response: :await})
  end
end

# TODO fazer o retorno caso de error
# TODO fazer o retorno caso de sucesso
