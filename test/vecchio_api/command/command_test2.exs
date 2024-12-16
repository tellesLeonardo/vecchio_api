defmodule MyProject.CommandTest do
  use ExUnit.Case, async: true

  alias VecchioApi.Command

  describe "Input validation" do
    test "input ABC represents the sequence of characters ABC" do
      assert Command.test("ABC") == "ABC"
    end

    test "input \"ABC\" represents the exact same sequence of characters ABC" do
      assert Command.test("ABC") == "ABC"
    end

    test "input 你好 represents the sequence of characters 你好" do
      assert Command.test("你好") == "你好"
    end

    test "input TRUE represents the boolean true" do
      assert Command.test(true) == true
    end

    test "input \"TRUE\" represents the string TRUE (not boolean)" do
      assert Command.test("TRUE") == "TRUE"
    end

    test "input AB C represents two separate entries: AB and C" do
      assert Command.test("AB C") == ["AB", "C"]
    end

    test "input \"AB C\" represents the string AB C" do
      assert Command.test("AB C") == "AB C"
    end

    test "input \"AB\"C\" is invalid because it contains an unmatched quote" do
      assert_raise ArgumentError, fn ->
        Command.test("AB\"C")
      end
    end

    test "input \"AB\\\"C\" represents the string AB\"C" do
      assert Command.test("AB\\\"C") == "AB\"C"
    end

    test "input a10 represents the sequence of characters a10" do
      assert Command.test("a10") == "a10"
    end

    test "input 10a represents the sequence of characters 10a" do
      assert Command.test("10a") == "10a"
    end

    test "input 10 represents the number 10" do
      assert Command.test(10) == 10
    end
  end
end
