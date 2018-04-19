defmodule VirtualMachine.ProgramTest do
  use ExUnit.Case

  test "Jumping in a program" do
    program = [6, 4, 19, ?A, 19, ?B]

    VirtualMachine.load_program(program)
    VirtualMachine.set_output(self())
    VirtualMachine.run()

    refute_receive(?A)
    assert_receive(?B)
  end
end
