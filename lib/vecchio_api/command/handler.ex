defmodule VecchioApi.Command.Handler do
  defstruct code: nil, key: nil, value: nil

  alias VecchioApi.Command.CommandParser
  alias VecchioApi.Command.SyntaxValidator

  @spec handle_command(binary()) ::
          {:error, <<_::64, _::_*8>>}
          | %VecchioApi.Command.Handler{
              code: any(),
              key: binary() | {integer(), integer()},
              value: boolean() | binary() | number()
            }
  def handle_command(input) do
    with {:ok, atom_command, _} <- SyntaxValidator.validate(input),
         {_command, key, value} <- CommandParser.parse(input),
         nil <- is_null_in_value(atom_command, value),
         nil <- is_null_in_key(atom_command, key)do
      %__MODULE__{code: atom_command, key: unescape_quotes(key), value: unescape_quotes(value)}
    else
      {:error, _} = error -> error
    end
  end

  defp is_null_in_value(command, value) when is_binary(value) do
    if String.upcase(value) == "NIL", do: {:error, "Cannot #{command} key to NIL"}
  end

  defp is_null_in_value(_command, _value), do: nil

  defp is_null_in_key(command, key) when is_binary(key) do
    if String.upcase(key) == "NIL", do: {:error, "Cannot #{command} NIL key"}
  end

  defp is_null_in_key(_command, _key), do: nil

  defp unescape_quotes(input) when is_binary(input) do
    input
    |> String.trim_leading("\"")
    |> String.trim_trailing("\"")
  end

  defp unescape_quotes(input), do: input
end
