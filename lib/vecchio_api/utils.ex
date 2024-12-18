defmodule VecchioApi.Utils do
  @moduledoc false

  @commands %{
    # SET requires a key and a value
    "SET" => %{atom: :set},
    # GET requires only a key
    "GET" => %{atom: :get},
    # BEGIN is an isolated command
    "BEGIN" => %{atom: :begin},
    # ROLLBACK is an isolated command
    "ROLLBACK" => %{atom: :rollback},
    # COMMIT is an isolated command
    "COMMIT" => %{atom: :commit}
  }

  @doc """
    search map commands
  """
  def get_commands, do: @commands
end
