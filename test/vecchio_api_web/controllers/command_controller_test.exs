defmodule VecchioApiWeb.CommandControllerTest do
  use VecchioApiWeb.ConnCase, async: true

  describe "command/2" do
    test "dont pass a client name", %{conn: conn} do
      # Definir os dados que você irá enviar para o controller
      data = %{"key" => "value"}

      # Realiza a requisição para o controller
      conn = post(conn, ~p"/", data)

      # Verificar o status da resposta
      assert json_response(conn, 400)["error"] == "Missing X-Client-Name header"
    end

    test "retorna status 200 e resposta correta", %{conn: conn} do
      # Definir os dados que você irá enviar para o controller
      data = %{"key" => "value"}

      conn = Plug.Conn.put_req_header(conn, "x-client-name", "test_user")

      # Realiza a requisição para o controller
      conn = post(conn, ~p"/", data)

      # Verificar o status da resposta
      assert json_response(conn, 200)["response"] == "await"
    end
  end
end
