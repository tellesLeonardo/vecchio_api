defmodule VecchioApi.Command.HandlerTest do
  use ExUnit.Case
  alias VecchioApi.Command.Handler

  describe "parse/1" do
    test "parses command with quoted key and boolean value" do
      assert Handler.handle_command(~s{SET "my_key" TRUE}) ==  %Handler{code: :set, key: "my_key", value: true, quotation: true}
      assert Handler.handle_command(~s{SET "my_key" FALSE}) == %Handler{code: :set, key: "my_key", value: false, quotation: true}
    end

    test "parses command with quoted key and integer value" do
      assert Handler.handle_command(~s{SET "my_key" 123}) == %Handler{code: :set, key: "my_key", value: 123, quotation: true}
    end

    test "parses command with quoted key and string value" do
      assert Handler.handle_command(~s{SET "my_key" some_string}) == %Handler{code: :set, key: "my_key", value: "some_string", quotation: true}
    end

    test "parses command with unquoted key and boolean value" do
      assert Handler.handle_command(~s{SET my_key TRUE}) == %Handler{code: :set, key: "my_key", value: true, quotation: false}
      assert Handler.handle_command(~s{SET my_key FALSE}) == %Handler{code: :set, key: "my_key", value: false, quotation: false}
    end

    test "parses command with unquoted key and integer value" do
      assert Handler.handle_command(~s{SET my_key 123}) == %Handler{code: :set, key: "my_key", value: 123, quotation: false}
    end

    test "parses command with unquoted key and string value" do
      assert Handler.handle_command(~s{SET my_key some_string}) == %Handler{code: :set, key: "my_key", value: "some_string", quotation: false}
    end

    test "parses command with multi-word unquoted key" do
      assert Handler.handle_command(~s{SET my multi word key 123}) == %Handler{code: :set, key: "my multi word key", value: 123, quotation: false}
    end

    test "returns error for invalid command format" do
      assert Handler.handle_command("INVALID_COMMAND") == {:error, "Unknown command: INVALID_COMMAND"}
    end

    test "parses command with key-value pair and handles mixed-case booleans as strings" do
      assert Handler.handle_command(~s{SET "key" "TRUE"}) == %Handler{code: :set, key: "key", value: "TRUE", quotation: true}
      assert Handler.handle_command(~s{SET key FALSE123}) == %Handler{code: :set, key: "key", value: "FALSE123", quotation: false}
    end

    test "parses command with extra spaces and trims correctly" do
      assert Handler.handle_command("SET   my_key     42") == %Handler{code: :set, key: "  my_key    ", value: 42, quotation: true}
    end

    test "handles missing key or value gracefully" do
      assert Handler.handle_command("SET") == {:error, "Invalid syntax for command SET"}
      assert Handler.handle_command("SET my_key") == {:error, "Invalid syntax for command SET"}
    end
  end
end
