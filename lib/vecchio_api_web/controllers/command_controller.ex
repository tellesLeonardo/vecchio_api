defmodule VecchioApiWeb.CommandController do
  use VecchioApiWeb, :controller

  alias VecchioApi.Command.Handler

  def command(conn, _data) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    IO.inspect(body, label: "#{__MODULE__}")

    body
    |> Handler.handle_command()
    |> IO.inspect(label: "#{__MODULE__}")

    conn
    |> put_status(:ok)
    |> json(%{response: :await})
  end
end
