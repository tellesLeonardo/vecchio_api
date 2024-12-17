defmodule VecchioApi.Command.HandlerTest do
  use ExUnit.Case
  alias VecchioApi.Command.Handler

  describe "handle_command/1" do
    test "validates and handles GET command" do
      input = "GET test_key"

      result = Handler.handle_command(input)

      expected_result = %VecchioApi.Command.Handler{
        code: :get,
        key: "test_key",
        value: nil,
        quotation: false
      }

      assert result == expected_result
    end

    test "validates and handles BEGIN command" do
      input = "BEGIN"

      result = Handler.handle_command(input)

      expected_result = %VecchioApi.Command.Handler{
        code: :begin,
        key: nil,
        value: nil,
        quotation: false
      }

      assert result == expected_result
    end

    test "validates and handles ROLLBACK command" do
      input = "ROLLBACK"

      result = Handler.handle_command(input)

      expected_result = %VecchioApi.Command.Handler{
        code: :rollback,
        key: nil,
        value: nil,
        quotation: false
      }

      assert result == expected_result
    end

    test "validates and handles COMMIT command" do
      input = "COMMIT"

      result = Handler.handle_command(input)

      expected_result = %VecchioApi.Command.Handler{
        code: :commit,
        key: nil,
        value: nil,
        quotation: false
      }

      assert result == expected_result
    end

    test "returns error for an unknown command" do
      input = "INVALID_COMMAND"

      result = Handler.handle_command(input)

      assert result == {:error, "Unknown command: INVALID_COMMAND"}
    end

    test "handles GET command with quotation marks around key" do
      input = "GET \"quoted_key\""

      result = Handler.handle_command(input)

      expected_result = %VecchioApi.Command.Handler{
        code: :get,
        key: "quoted_key",
        value: nil,
        quotation: false
      }

      assert result == expected_result
    end

    test "handles BEGIN command with no key or value" do
      input = "BEGIN"

      result = Handler.handle_command(input)

      expected_result = %VecchioApi.Command.Handler{
        code: :begin,
        key: nil,
        value: nil,
        quotation: false
      }

      assert result == expected_result
    end
  end
end
