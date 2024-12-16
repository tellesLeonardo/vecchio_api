defmodule VecchioApiWeb.Plugs.RequestLogger do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    start_time = System.monotonic_time(:millisecond)
    conn = assign(conn, :start_time, start_time)
    Logger.info("Request started: #{conn.method} #{conn.request_path}")

    conn
    |> register_before_send(&log_request/1)
  end

  defp log_request(conn) do
    duration = System.monotonic_time(:millisecond) - conn.assigns[:start_time]
    Logger.info("Request finished: #{conn.method} #{conn.request_path} with status #{conn.status} in #{duration} ms")
    conn
  end
end
