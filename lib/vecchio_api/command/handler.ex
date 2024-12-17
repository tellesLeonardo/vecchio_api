defmodule VecchioApi.Command.Handler do
  defstruct code: nil, key: nil, value: nil, quotation: false

  alias VecchioApi.Command.CommandParser
  alias VecchioApi.Command.SyntaxValidator

  @spec handle_command(binary()) ::
          {:error, <<_::64, _::_*8>>}
          | %VecchioApi.Command.Handler{
              code: any(),
              key: binary() | {integer(), integer()},
              quotation: boolean(),
              value: boolean() | binary() | number()
            }
  def handle_command(input) do
    with {:ok, atom_command, _} <- SyntaxValidator.validate(input),
         {_command, key, value, quotation} <- CommandParser.parse(input) do
      %__MODULE__{code: atom_command, key: unescape_quotes(key), value: unescape_quotes(value), quotation: quotation}
    else
      {:error, _} = error -> error
    end
  end

  defp unescape_quotes(input) when is_binary(input) do
    input
    |> String.trim_leading("\"")
    |> String.trim_trailing("\"")
  end

  defp unescape_quotes(input), do: input
end
