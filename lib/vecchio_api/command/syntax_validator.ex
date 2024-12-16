defmodule VecchioApi.Command.SyntaxValidator do
  @moduledoc """
  Validação de sintaxe para os comandos suportados no sistema.
  """

  @commands %{
    # SET exige uma chave e um valor
    "SET" => %{regex: ~r/^SET (\w+) (.+)$/, atom: :set},
    # GET exige apenas uma chave
    "GET" => %{regex: ~r/^GET (\w+)$/, atom: :get},
    # BEGIN é um comando isolado
    "BEGIN" => %{regex: ~r/^BEGIN$/, atom: :begin},
    # ROLLBACK é um comando isolado
    "ROLLBACK" => %{regex: ~r/^ROLLBACK$/, atom: :rollback},
    # COMMIT é um comando isolado
    "COMMIT" => %{regex: ~r/^COMMIT$/, atom: :commit}
  }

  @doc """
  Valida a sintaxe de um comando.

  ## Exemplos
      iex> CommandValidator.validate("SET test 1")
      {:ok, "SET", ["test", "1"]}

      iex> CommandValidator.validate("GET test")
      {:ok, "GET", ["test"]}

      iex> CommandValidator.validate("BEGIN")
      {:ok, "BEGIN", []}

      iex> CommandValidator.validate("INVALID")
      {:error, "Unknown command: INVALID"}
  """
  def validate(input) do
    case String.split(input, ~r/\s+/, parts: 2) do
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

      data_regex ->
        with true <- Regex.match?(data_regex.regex, input),
             args <- Regex.run(data_regex.regex, input, capture: :all_but_first),
             :ok <- exists_nil_value(args) do
          {:ok, data_regex.atom, args}
        else
          false ->
            {:error, "Invalid syntax for command #{command}"}

          :nil_value_error ->
            {:error, "nil value is not allowed. #{input}"}
        end
    end
  end

  defp exists_nil_value(args) do
    if "nil" in args, do: :nil_value_error, else: :ok
  end
end
