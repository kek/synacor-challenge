defmodule VirtualMachine.BytecodeTest do
  use ExUnit.Case

  import VirtualMachine.Bytecode

  describe "parse" do
    test "transforms bytecode into instructions and data" do
      assert parse([19, ?A, 19, ?A]) == [{:out, ?A}, {:out, ?A}]
      assert parse([0]) == [{:halt}]
      assert parse([?A]) == [?A]

      assert parse([0]) == [{:halt}]
      assert parse([1, 100, 200]) == [{:set, 100, 200}]
      assert parse([2, 100]) == [{:push, 100}]
      assert parse([3, 100]) == [{:pop, 100}]
      assert parse([4, 100, 200, 300]) == [{:eq, 100, 200, 300}]
      assert parse([5, 100, 200, 300]) == [{:gt, 100, 200, 300}]
      assert parse([6, 100]) == [{:jmp, 100}]
      assert parse([7, 100, 200]) == [{:jt, 100, 200}]
      assert parse([8, 100, 200]) == [{:jf, 100, 200}]
      assert parse([9, 100, 200, 300]) == [{:add, 100, 200, 300}]
      assert parse([10, 100, 200, 300]) == [{:mult, 100, 200, 300}]
      assert parse([11, 100, 200, 300]) == [{:mod, 100, 200, 300}]
      assert parse([12, 100, 200, 300]) == [{:and, 100, 200, 300}]
      assert parse([13, 100, 200, 300]) == [{:or, 100, 200, 300}]
      assert parse([14, 100, 200]) == [{:not, 100, 200}]
      assert parse([15, 100, 200]) == [{:rmem, 100, 200}]
      assert parse([16, 100, 200]) == [{:wmem, 100, 200}]
      assert parse([17, 100]) == [{:call, 100}]
      assert parse([18]) == [{:ret}]
      assert parse([19, 100]) == [{:out, 100}]
      assert parse([20, 100]) == [{:in, 100}]
      assert parse([21]) == [{:noop}]
    end
  end
end
