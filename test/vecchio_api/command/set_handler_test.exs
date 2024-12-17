defmodule VecchioApi.Command.SetHandlerTest do
  use ExUnit.Case
  alias VecchioApi.Command.Handler

  describe "parse/1" do
    test "parses SET command with quoted key and boolean value" do
      assert Handler.handle_command(~s{SET "my_key" TRUE}) == %Handler{
               code: :set,
               key: "my_key",
               value: true,
               quotation: true
             }

      assert Handler.handle_command(~s{SET "my_key" FALSE}) == %Handler{
               code: :set,
               key: "my_key",
               value: false,
               quotation: true
             }
    end

    test "parses SET command with quoted key and integer value" do
      assert Handler.handle_command(~s{SET "my_key" "123"}) == %Handler{
               code: :set,
               key: "my_key",
               value: "123",
               quotation: true
             }
    end

    test "parses SET command with quoted key and string value" do
      assert Handler.handle_command(~s{SET "my_key" some_string}) == %Handler{
               code: :set,
               key: "my_key",
               value: "some_string",
               quotation: true
             }
    end

    test "parses SET command with unquoted key and boolean value" do
      assert Handler.handle_command(~s{SET my_key TRUE}) == %Handler{
               code: :set,
               key: "my_key",
               value: true,
               quotation: false
             }

      assert Handler.handle_command(~s{SET my_key FALSE}) == %Handler{
               code: :set,
               key: "my_key",
               value: false,
               quotation: false
             }
    end

    test "parses SET command with unquoted key and integer value" do
      assert Handler.handle_command(~s{SET my_key 123}) == %Handler{
               code: :set,
               key: "my_key",
               value: 123,
               quotation: false
             }
    end

    test "parses SET command with unquoted key and string value" do
      assert Handler.handle_command(~s{SET my_key some_string}) == %Handler{
               code: :set,
               key: "my_key",
               value: "some_string",
               quotation: false
             }
    end

    test "parses SET command with multi-word unquoted key" do
      assert Handler.handle_command(~s{SET my multi word key 123}) == %Handler{
               code: :set,
               key: "my multi word key",
               value: 123,
               quotation: false
             }
    end

    test "returns error for unknown command format" do
      assert Handler.handle_command("INVALID_COMMAND") ==
               {:error, "Unknown command: INVALID_COMMAND"}
    end

    test "parses SET command with key-value pair and handles mixed-case booleans as strings" do
      assert Handler.handle_command(~s{SET "key" "TRUE"}) == %Handler{
               code: :set,
               key: "key",
               value: "TRUE",
               quotation: true
             }

      assert Handler.handle_command(~s{SET key FALSE123}) == %Handler{
               code: :set,
               key: "key",
               value: "FALSE123",
               quotation: false
             }
    end

    test "parses SET command with key-value pair and handles mixed-case booleans as strings" do
      assert Handler.handle_command(~s{SET TRUE TRUE}) == %Handler{
               code: :set,
               key: "TRUE",
               value: true,
               quotation: false
             }
    end

    test "parses SET command with extra spaces and trims correctly" do
      assert Handler.handle_command("SET \"my key\" 42") == %Handler{
               code: :set,
               key: "my key",
               value: 42,
               quotation: true
             }
    end

    test "returns error for missing key or value in SET command" do
      assert Handler.handle_command("SET") == {:error, "Invalid syntax for command set"}
      assert Handler.handle_command("SET my_key") == {:error, "Invalid syntax for command set"}
    end
  end

  test "correctly handles values with spaces in SET command" do
    assert Handler.handle_command(~s{SET "key" "value with spaces"}) == %Handler{
             code: :set,
             key: "key",
             value: "value with spaces",
             quotation: true
           }
  end

  test "parses SET command with alphanumeric string value" do
    assert Handler.handle_command(~s{SET my_key a10}) == %Handler{
             code: :set,
             key: "my_key",
             value: "a10",
             quotation: false
           }
  end

  test "handles empty key gracefully in SET command" do
    assert Handler.handle_command("SET  \"\" 42") ==
             {:error, "Nil value is not allowed. SET  \"\" 42"}
  end

  test "returns error for SET command with unmatched quote" do
    assert Handler.handle_command(~s{SET "AB"C}) == {:error, "Invalid syntax for command set"}
  end

  test "parses SET command with escaped quote inside value" do
    assert Handler.handle_command("SET \"AB\\\"C\" 123") == %Handler{
             code: :set,
             key: "AB\\\"C",
             value: 123,
             quotation: false
           }
  end
end
