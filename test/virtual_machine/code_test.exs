defmodule VirtualMachine.CodeTest do
  use ExUnit.Case

  import VirtualMachine.Code

  describe "parse" do
    test "transforms bytecode into instructions and data" do
      assert parse([]) == {}
      assert parse([19, ?A, 19, ?A]) == {:out, ?A}
      assert parse([0]) == {:halt}
      assert parse([1, ?A, ?B]) == {:set, ?A, ?B}
      assert parse([2, ?A]) == {:push, ?A}
      assert parse([3, ?A]) == {:pop, ?A}
      assert parse([4, ?A, ?B, ?C]) == {:eq, ?A, ?B, ?C}
      assert parse([5, ?A, ?B, ?C]) == {:gt, ?A, ?B, ?C}
      assert parse([6, ?A]) == {:jmp, ?A}
      assert parse([7, ?A, ?B]) == {:jt, ?A, ?B}
      assert parse([8, ?A, ?B]) == {:jf, ?A, ?B}
      assert parse([9, ?A, ?B, ?C]) == {:add, ?A, ?B, ?C}
      assert parse([10, ?A, ?B, ?C]) == {:mult, ?A, ?B, ?C}
      assert parse([11, ?A, ?B, ?C]) == {:mod, ?A, ?B, ?C}
      assert parse([12, ?A, ?B, ?C]) == {:and, ?A, ?B, ?C}
      assert parse([13, ?A, ?B, ?C]) == {:or, ?A, ?B, ?C}
      assert parse([14, ?A, ?B]) == {:not, ?A, ?B}
      assert parse([15, ?A, ?B]) == {:rmem, ?A, ?B}
      assert parse([16, ?A, ?B]) == {:wmem, ?A, ?B}
      assert parse([17, ?A]) == {:call, ?A}
      assert parse([18]) == {:ret}
      assert parse([19, ?A]) == {:out, ?A}
      assert parse([20, ?A]) == {:in, ?A}
      assert parse([21]) == {:noop}
      assert parse([21 | [1, 2, 3]]) == {:noop}
    end
  end

  describe "read" do
    test "reads bytes from the file" do
      bytes = read("priv/challenge.bin")
      assert [0x15, 0x15, 0x13, 0x57, 0x13, 0x65, 0x13, 0x6C] ++ _ = bytes

      bytes =
        read("priv/challenge.bin")
        |> Enum.drop(504)

      assert [0x8001, 0x445, 0x7, 0x8002] ++ _ = bytes
    end
  end
end
