defmodule VecchioApiWeb.CommandControllerTest do
  use VecchioApiWeb.ConnCase

  describe "command/2" do
    test "dont pass a client name", %{conn: conn} do
      # Definir os dados que você irá enviar para o controller
      data = "SET key value"

      # Realiza a requisição para o controller
      conn =
        conn
        |> put_req_header("content-type", "text/plain")
        |> post(~p"/", data)

      # Verificar o status da resposta
      assert text_response(conn, 400) == "Missing X-Client-Name header"
    end

    test "returns status 200 and correct response", %{conn: conn} do
      # Definir os dados que você irá enviar para o controller
      data = "SET key value"

      conn = Plug.Conn.put_req_header(conn, "x-client-name", "test_user")

      # Realiza a requisição para o controller
      conn =
        conn
        |> put_req_header("content-type", "text/plain")
        |> post(~p"/", data)

      # Verificar o status da resposta
      assert text_response(conn, 200) == "NIL value"
    end
  end
end
