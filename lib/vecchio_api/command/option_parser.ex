defmodule VecchioApi.Command.OptionParser do
  @moduledoc """
  A module for splitting command strings into parts, respecting quotes and escaped characters.

  This module is useful for processing input strings that follow patterns
  similar to terminal commands, where quoted values need to be preserved,
  including escaped characters.

  ## Usage Examples

      iex> VecchioApi.Command.OptionParser.split(~s(SET "AB\\\"C" 123))
      {:ok, ["SET", "AB\\\"C", "123"]}

      iex> VecchioApi.Command.OptionParser.split(~s(COMMAND "Hello World" true))
      {:ok, ["COMMAND", "Hello World", "true"]}
  """

  @doc """
  Splits an input string into parts, preserving quoted content and escaped characters.

  ## Parameters
    - `text` (string): The input string to be split.

  ## Return
    - `{:ok, list}`: Returns a tuple with the list of split parts.

  ## Examples

      iex> VecchioApi.Command.OptionParser.split("SET ABC 123")
      {:ok, ["SET", "ABC", "123"]}

      iex> VecchioApi.Command.OptionParser.split(~s(SET "AB C" 10))
      {:ok, ["SET", "AB C", "10"]}
  """
  def split(text) do
    regex = ~r/"((?:\\.|[^"\\])*)"|[^\s]+/

    data =
      Regex.scan(regex, text)
      |> Enum.map(fn
        [word] -> word
        [word, _quoted] -> word
      end)

    {:ok, data}
  end
end
