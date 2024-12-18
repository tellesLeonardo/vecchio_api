defmodule VecchioApi.Command.Handler do
  @moduledoc """
  A module responsible for handling commands by processing the input
  and returning a structured result or error.

  The handler works in conjunction with the `OptionParser`, `SyntaxValidator`,
  and `CommandParser` modules to split the input, validate its syntax,
  and parse the command.

  ## Examples

      iex> VecchioApi.Command.Handler.handle_command("SET key 123")
      %VecchioApi.Command.Handler{code: :set, key: "key", value: 123}

      iex> VecchioApi.Command.Handler.handle_command("GET key")
      %VecchioApi.Command.Handler{code: :get, key: "key", value: nil}

      iex> VecchioApi.Command.Handler.handle_command("INVALID input")
      {:error, "Invalid command syntax"}
  """

  defstruct code: nil, key: nil, value: nil

  alias VecchioApi.Command.{CommandParser, OptionParser, SyntaxValidator}

  @spec handle_command(binary()) ::
          {:error, String.t()}
          | %VecchioApi.Command.Handler{
              code: any(),
              key: binary() | {integer(), integer()},
              value: boolean() | binary() | number()
            }

  @doc """
  Handles the command input by splitting, validating, and parsing it.

  ## Parameters

    - `input`: A binary string representing the command to be processed.

  ## Return

    - On success, returns a `%VecchioApi.Command.Handler{}` struct with the parsed command details.
    - On failure, returns an error tuple `{:error, reason}`.

  ## Examples

      iex> VecchioApi.Command.Handler.handle_command("SET key 123")
      %VecchioApi.Command.Handler{code: :set, key: "key", value: 123}

      iex> VecchioApi.Command.Handler.handle_command("BEGIN")
      %VecchioApi.Command.Handler{code: :begin, key: nil, value: nil}

      iex> VecchioApi.Command.Handler.handle_command("INVALID COMMAND")
      {:error, "No command INVALID COMMAND"}
  """
  def handle_command(input) do
    with {:ok, data} <- OptionParser.split(input),
         :ok <- SyntaxValidator.validate(data),
         {code, key, value} <- CommandParser.parse(data) do
      %__MODULE__{code: code, key: key, value: value}
    else
      error -> error
    end
  end
end
