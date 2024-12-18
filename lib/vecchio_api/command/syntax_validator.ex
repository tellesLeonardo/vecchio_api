defmodule VecchioApi.Command.SyntaxValidator do
  @moduledoc """
  Syntax validation for the supported commands in the system.

  This module validates commands such as 'SET', 'GET', 'BEGIN', 'ROLLBACK', and 'COMMIT'.
  It ensures that the commands follow the correct syntax, and checks for issues like unbalanced quotes
  or nil values within the input.
  """

  @commands %{
    # SET requires a key and a value
    "SET" => %{
      regexs: [~r/^SET\s+"?([\w_]+)"?\s+"?(.+?)"?$/, ~r/^SET\s+"((?:\\\\|\\\"|[^"\\])*)"\s+(.+)$/],
      atom: :set
    },
    # GET requires only a key
    "GET" => %{regex: ~r/^GET\s+"?([\w_]+)"?$/, atom: :get},
    # BEGIN is an isolated command
    "BEGIN" => %{regex: ~r/^BEGIN$/, atom: :begin},
    # ROLLBACK is an isolated command
    "ROLLBACK" => %{regex: ~r/^ROLLBACK$/, atom: :rollback},
    # COMMIT is an isolated command
    "COMMIT" => %{regex: ~r/^COMMIT$/, atom: :commit}
  }

  @doc """
  Validates the syntax of a given command.

  This function splits the input command into the command name and arguments and
  checks if the command follows the correct syntax.

  ## Examples
      iex> SyntaxValidator.validate("SET test 1")
      {:ok, "SET", ["test", "1"]}

      iex> SyntaxValidator.validate("GET test")
      {:ok, "GET", ["test"]}

      iex> SyntaxValidator.validate("BEGIN")
      {:ok, "BEGIN", []}

      iex> SyntaxValidator.validate("INVALID")
      {:error, "Unknown command: INVALID"}
  """
  def validate(input) do
    case String.split(input, ~r/\s+/, parts: 2) do
      [command] ->
        validate_command(command, nil)

      [command | _] ->
        validate_command(command, input)

      _ ->
        {:error, "Invalid command format"}
    end
  end

  defp validate_command(command, input) do
    case Map.get(@commands, command) do
      nil ->
        {:error, "Unknown command: #{command}"}

      command_data when command_data.atom in [:begin, :rollback, :commit] ->
        {:ok, command_data.atom, []}

      command_data ->
        validate_command_syntax(command_data, input)
    end
  end

  defp validate_command_syntax(command_data, input) do
    with {:ok, args} <- match_command(command_data, input),
         :ok <- validate_no_nil_value(args),
         :ok <- validate_no_unbalanced_quotes(args) do
      {:ok, command_data.atom, args}
    else
      {:error, _} ->
        {:error, "Invalid syntax for command #{command_data.atom}"}

      :nil_value_error ->
        {:error, "Nil value is not allowed. #{input}"}

      :unbalanced_quotes_error ->
        {:error, "The input contains an unmatched quote."}
    end
  end

  @doc """
  Matches the command input with the defined regular expressions.

  ## Examples
      iex> SyntaxValidator.match_command(%{regexs: [~r/^SET (\w+)/]}, "SET key 1")
      {:ok, ["key", "1"]}

      iex> SyntaxValidator.match_command(%{regex: ~r/^GET (\w+)/}, "GET key")
      {:ok, ["key"]}
  """
  defp match_command(_data, nil), do: {:error, ["syntaxt error"]}

  defp match_command(%{regexs: regexs}, input) do
    if Enum.any?(regexs, &Regex.match?(&1, input)) do
      args = get_list_args(regexs, input)
      {:ok, args}
    else
      {:error, []}
    end
  end

  defp match_command(%{regex: regex}, input) do
    if Regex.match?(regex, input) do
      {:ok, Regex.run(regex, input, capture: :all_but_first)}
    else
      {:error, []}
    end
  end

  defp get_list_args(regexs, input) do
    Enum.flat_map(regexs, fn regex ->
      case Regex.run(regex, input, capture: :all_but_first) do
        nil -> []
        args -> args
      end
    end)
  end

  @doc """
  Validates that no arguments are nil or empty.

  This function checks if any argument is a string containing the word "nil" or an empty string.

  ## Examples
      iex> SyntaxValidator.validate_no_nil_value(["key", "value"])
      :ok

      iex> SyntaxValidator.validate_no_nil_value(["key", "nil"])
      :nil_value_error
  """
  defp validate_no_nil_value(args) do
    case {"nil" in args, "" in args} do
      {false, false} -> :ok
      _ -> :nil_value_error
    end
  end

  @doc """
  Validates that no arguments contain unbalanced single quotes.

  This function checks if any argument contains an unbalanced single quote, which would
  make the input invalid.

  ## Examples
      iex> SyntaxValidator.validate_no_unbalanced_quotes(["key"])
      :ok

      iex> SyntaxValidator.validate_no_unbalanced_quotes(["It's a test"])
      :unbalanced_quotes_error
  """
  defp validate_no_unbalanced_quotes(args) do
    args
    |> Enum.map(&has_unbalanced_quotes?(&1))
    |> Enum.any?(&(&1 == true))
    |> case do
      true -> :unbalanced_quotes_error
      false -> :ok
    end
  end

  @doc """
  Checks if a given value has unbalanced single quotes.

  ## Examples
      iex> SyntaxValidator.has_unbalanced_quotes?("It's a test")
      true

      iex> SyntaxValidator.has_unbalanced_quotes?("key")
      false
  """
  defp has_unbalanced_quotes?(value) do
    Regex.match?(~r/[^\\]'[^']*$/, value)
  end
end
