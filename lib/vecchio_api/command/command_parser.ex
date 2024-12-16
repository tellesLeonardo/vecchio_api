defmodule VecchioApi.Command.CommandParser do
  def parse(input) do
    case String.split(input, ~r/\s+/, parts: 2) do
      [command, rest] ->
        parse_key_value(command, rest)

      _ ->
        {:error, "Invalid command"}
    end
  end

  defp parse_key_value(command, rest) do
    case Regex.run(~r/^"([^"]+)"\s+(.+)$/, rest) do
      [_, key, value] ->
        {command, key, convert_value(value), true}

      _ ->
        parts = String.split(rest, ~r/\s+/)
        {key, value} = extract_key_value(parts)
        {command, key, convert_value(value), false}
    end
  end

  defp extract_key_value(parts) do
    case Enum.split(parts, -1) do
      {key_parts, [value]} ->
        key = Enum.join(key_parts, " ")
        {key, value}
    end
  end

  defp convert_value(value) do
    cond do
      # Verifica se o valor é um booleano
      value in ["TRUE", "FALSE"] ->
        String.upcase(value) == "TRUE"

      # Verifica se o valor é um número inteiro
      to_int(value) ->
        String.to_integer(value)

      # Verifica se o valor é um número decimal
      to_float(value) ->
        String.to_float(value)

      # Se não for nenhum dos anteriores, retorna como string
      true ->
        value
    end
  end

  defp to_int(value) do
    case Integer.parse(value) do
      :error -> false
      {int_value, _} -> int_value != nil
    end
  end

  defp to_float(value) do
    case Float.parse(value) do
      :error -> false
      {int_value, _} -> int_value != nil
    end
  end
end
