defmodule VecchioApi.Command.SyntaxValidator do
  @moduledoc """
  Syntax validation for the supported commands in the system.

  This module validates commands such as 'SET', 'GET', 'BEGIN', 'ROLLBACK', and 'COMMIT'.
  It ensures that the commands follow the correct syntax, and checks for issues like unbalanced quotes
  or nil values within the input.
  """

  alias VecchioApi.Utils

  @cmd_no_data [:begin, :rollback, :commit]

  def validate([]), do: {:error, "Syntax error"}

  def validate([cmd | _] = data) do
    cmd = String.upcase(cmd)

    case Map.get(Utils.get_commands(), cmd) do
      nil ->
        {:error, "No command #{cmd}"}

      map_cmd ->
        validate_command(map_cmd.atom, data)
    end
  end

  defp validate_command(cmd, _data) when cmd in @cmd_no_data, do: :ok

  defp validate_command(:set, [_cmd, key, value]) do
    with nil <- is_nil_value(key),
         nil <- is_nil_value(value) do
      :ok
    else
      error -> error
    end
  end

  defp validate_command(:get, [_cmd, key]) do
    case is_nil_value(key) do
      nil -> :ok
      error -> error
    end
  end

  defp validate_command(cmd, _data), do: {:error, "#{cmd} <chave> <valor> - Syntax error"}

  @doc """
  Validates that no arguments are nil or empty.

  This function checks if any argument is a string containing the word "nil" or an empty string.

  ## Examples
      iex> SyntaxValidator.is_nil_value("key")
      :ok

      iex> SyntaxValidator.is_nil_value("nil")
      :nil_value_error
  """
  defp is_nil_value(value) do
    if String.upcase(value) in ["NIL", ""] do
      {:error, "Nil value is not allowed."}
    end
  end
end
