defmodule VecchioApi.Command.CommandParserTest do
  use ExUnit.Case
  alias VecchioApi.Command.CommandParser

  describe "parse/1" do
    test "parses a SET command with valid inputs" do
      assert CommandParser.parse(["SET", "key", "123"]) == {:set, "key", 123}
    end

    test "parses a GET command with a valid key" do
      assert CommandParser.parse(["GET", "key"]) == {:get, "key", nil}
    end

    test "parses BEGIN command with no data" do
      assert CommandParser.parse(["BEGIN"]) == {:begin, nil, nil}
    end
  end

  describe "convert_type/1" do
    test "converts a boolean string to its respective type" do
      assert CommandParser.convert_type("TRUE") == true
      assert CommandParser.convert_type("FALSE") == false
    end

    test "converts numeric strings to integers or floats" do
      assert CommandParser.convert_type("123") == 123
      assert CommandParser.convert_type("12.34") == 12.34
    end

    test "returns a string if the value is not boolean or numeric" do
      assert CommandParser.convert_type("text") == "text"
    end
  end

  describe "valid_key/1" do
    test "validates a valid string key" do
      assert CommandParser.valid_key("key") == {:ok, "key"}
    end

    test "returns an error for non-string keys" do
      assert CommandParser.valid_key(123) == {:error, "Value 123 is not valid as key"}
    end
  end
end
