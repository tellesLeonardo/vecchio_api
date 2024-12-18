defmodule VecchioApi.Command.CommandParser do
  @moduledoc """
  Parses and processes commands with varying parameters.

  Supports commands such as `SET`, `GET`, `BEGIN`, `ROLLBACK`, and `COMMIT`,
  converting values to appropriate types and validating inputs as needed.

  ## Examples

      iex> CommandParser.parse(["SET", "key", "123"])
      {:set, "key", 123}

      iex> CommandParser.parse(["GET", "key"])
      {:get, "key", nil}

      iex> CommandParser.parse(["BEGIN"])
      {:begin, nil, nil}
  """

  alias VecchioApi.Utils
  @cmd_no_data [:begin, :rollback, :commit]

  @doc """
  Parses a command and extracts its operation, key, and value if applicable.

  ## Parameters

    - `data`: A list where the first element is the command and subsequent elements are arguments.

  ## Return

    - A tuple with the command's atom representation and its parameters.

  ## Examples

      iex> CommandParser.parse(["SET", "key", "TRUE"])
      {:set, "key", true}

      iex> CommandParser.parse(["ROLLBACK"])
      {:rollback, nil, nil}
  """
  def parse([cmd | _] = data) do
    cmd = String.upcase(cmd)

    Utils.get_commands()
    |> Map.get(cmd)
    |> Map.get(:atom)
    |> parser_command(data)
  end

  defp parser_command(code, _data) when code in @cmd_no_data, do: {code, nil, nil}

  defp parser_command(:set, data) do
    [_, key, value] = data

    with {:ok, key} <- valid_key(convert_type(key)) do
      {:set, key, convert_type(value)}
    else
      {:error, _} = error -> error
    end
  end

  defp parser_command(:get, data) do
    [_, key] = data

    with {:ok, key} <- valid_key(convert_type(key)) do
      {:get, key, nil}
    else
      {:error, _} = error -> error
    end
  end

  @doc """
  Converts a string to its appropriate type: boolean, integer, float, or string.

  ## Examples

      iex> CommandParser.convert_type("TRUE")
      true

      iex> CommandParser.convert_type("123")
      123

      iex> CommandParser.convert_type("12.34")
      12.34

      iex> CommandParser.convert_type("text")
      "text"
  """
  def convert_type(value) do
    cond do
      value in ["TRUE", "FALSE"] ->
        String.upcase(value) == "TRUE"

      valid_integer?(value) ->
        String.to_integer(value)

      valid_float?(value) ->
        String.to_float(value)

      true ->
        value
    end
  end

  @doc """
  Validates that a key is a string.

  ## Examples

      iex> CommandParser.valid_key("key")
      {:ok, "key"}

      iex> CommandParser.valid_key(123)
      {:error, "Value 123 is not valid as key"}
  """
  def valid_key(key) do
    if is_binary(key), do: {:ok, key}, else: {:error, "Value #{key} is not valid as key"}
  end

  @doc """
  Determines if a value can be parsed as an integer.

  ## Examples

      iex> CommandParser.valid_integer?("123")
      true

      iex> CommandParser.valid_integer?("abc")
      false
  """
  defp valid_integer?(value) do
    case Integer.parse(value) do
      {_int_value, ""} -> true
      _ -> false
    end
  end

  @doc """
  Determines if a value can be parsed as a float.

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
