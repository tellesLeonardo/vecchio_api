defmodule VecchioApi.Command.CommandParser do
  @moduledoc """
  A module for parsing commands in the system.

  It is responsible for parsing commands such as SET, GET, BEGIN, ROLLBACK, and COMMIT,
  extracting the key-value pairs or handling command-specific parameters.
  """

  @doc """
  Parses an input command string.

  ## Examples

      iex> CommandParser.parse("SET \"key\" value")
      {"SET", "key", "value", true}

      iex> CommandParser.parse("GET key")
      {"GET", "key", nil, false}

      iex> CommandParser.parse("BEGIN")
      {"BEGIN", nil, nil, false}

      iex> CommandParser.parse("INVALID")
      {:error, "Invalid command"}

  """
  def parse(input) do
    case String.split(input, ~r/\s+/, parts: 2) do
      [command] ->
        parse_command_with_key_value(command, nil)

      [command, rest] ->
        parse_command_with_key_value(command, rest)

      _ ->
        {:error, "Invalid command"}
    end
  end

  @doc """
  Parses the command and its arguments for commands that accept a key-value structure.

  ## Examples

      iex> CommandParser.parse_command_with_key_value("SET", "\"key\" value")
      {"SET", "key", "value", true}

      iex> CommandParser.parse_command_with_key_value("SET", "key value")
      {"SET", "key", "value", false}

      iex> CommandParser.parse_command_with_key_value("GET", "key")
      {"GET", "key", nil, false}

  """
  defp parse_command_with_key_value("SET", rest) do
    case Regex.run(~r/^"([^"]+)"\s+(.+)$/, rest) do
      [_, key, value] ->
        {"SET", key, convert_value(value), true}

      _ ->
        parts = String.split(rest, ~r/\s+/)
        {key, value} = extract_key_value(parts)
        {"SET", key, convert_value(value), false}
    end
  end

  defp parse_command_with_key_value(command, rest) do
    {command, rest, nil, false}
  end

  @doc """
  Extracts the key-value pair from a list of string parts.

  ## Examples

      iex> CommandParser.extract_key_value(["key", "value"])
      {"key", "value"}

      iex> CommandParser.extract_key_value(["long key", "value"])
      {"long key", "value"}

  """
  defp extract_key_value(parts) do
    case Enum.split(parts, -1) do
      {key_parts, [value]} ->
        key = Enum.join(key_parts, " ")
        {key, value}
    end
  end

  @doc """
  Converts a string value into the appropriate type (boolean, integer, float, or string).

  ## Examples

      iex> CommandParser.convert_value("TRUE")
      true

      iex> CommandParser.convert_value("123")
      123

      iex> CommandParser.convert_value("12.34")
      12.34

      iex> CommandParser.convert_value("string_value")
      "string_value"

  """
  defp convert_value(value) do
    cond do
      # Check if the value is a boolean
      value in ["TRUE", "FALSE"] ->
        String.upcase(value) == "TRUE"

      # Check if the value is an integer
      valid_integer?(value) ->
        String.to_integer(value)

      # Check if the value is a float
      valid_float?(value) ->
        String.to_float(value)

      # Default: return as a string
      true ->
        value
    end
  end

  @doc """
  Checks if a value can be parsed as an integer.

  ## Examples

      iex> CommandParser.valid_integer?("123")
      true

      iex> CommandParser.valid_integer?("12.34")
      false

  """
  defp valid_integer?(value) do
    case Integer.parse(value) do
      {_int_value, ""} -> true
      _ -> false
    end
  end

  @doc """
  Checks if a value can be parsed as a float.

  ## Examples

      iex> CommandParser.valid_float?("12.34")
      true

      iex> CommandParser.valid_float?("123")
      false

  """
  defp valid_float?(value) do
    case Float.parse(value) do
      {_float_value, ""} -> true
      _ -> false
    end
  end
end
