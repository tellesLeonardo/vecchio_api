defmodule VecchioApi.Plugs.ClientName do
  import Plug.Conn

  @behaviour Plug

  @doc """
  Inicializa o plug. Por padrão, não necessita de nenhuma configuração.
  """
  def init(opts), do: opts

  @doc """
  Executa o plug. Verifica se o cabeçalho `X-Client-Name` está presente na requisição.
  - Adiciona o valor no `conn.assigns[:client_name]` se encontrado.
  - Retorna `400 Bad Request` caso o cabeçalho esteja ausente.
  """
  def call(conn, _opts) do
    case get_req_header(conn, "x-client-name") do
      [client_name | _] ->
        assign(conn, :client_name, client_name)

      [] ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(400, "Missing X-Client-Name header")
        |> halt()
    end
  end
end
