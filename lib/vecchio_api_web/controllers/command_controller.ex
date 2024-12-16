defmodule VecchioApiWeb.CommandController do
  use VecchioApiWeb, :controller

  def command(conn, data) do
    IO.inspect(data, label: "#{__MODULE__}")

    conn
    |> put_status(:ok)
    |> json(%{response: :await})
  end
end
