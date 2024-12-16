defmodule VecchioApi.Command.Handler do
  defstruct code: nil, key: nil, value: nil, quotation: false

  alias VecchioApi.Command.CommandParser
  alias VecchioApi.Command.SyntaxValidator

  def handle_command(input) do
    with {:ok, atom_command, _} <- SyntaxValidator.validate(input),
         {_command, key, value, quotation} <- CommandParser.parse(input) do
      %__MODULE__{code: atom_command, key: key, value: value, quotation: quotation}
    else
      {:error, _} = error -> error
    end
  end
end
