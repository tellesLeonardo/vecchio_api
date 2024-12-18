defmodule VecchioApi.Command.OptionParserTest do
  use ExUnit.Case

  alias VecchioApi.Command.OptionParser

  describe "split/1" do
    test "divide string simples sem aspas" do
      assert OptionParser.split("SET ABC 123") == {:ok, ["SET", "ABC", "123"]}
    end

    test "preserva conteúdo entre aspas" do
      assert OptionParser.split(~s(SET "AB C" 10)) == {:ok, ["SET", "\"AB C\"", "10"]}
    end

    test "lida com caracteres escapados dentro de aspas" do
      assert OptionParser.split(~s(SET "AB\\\"C" 123)) == {:ok, ["SET", "\"AB\\\"C\"", "123"]}
    end
  end
end
