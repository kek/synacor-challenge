defmodule VirtualMachineTest do
  use ExUnit.Case
  doctest VirtualMachine

  # test "running the example program outputs the character in register 0 incremented by 4" do
  #   program = [9, 32768, 32769, 4, 19, 32768]

  #   VirtualMachine.load_program(program)

  #   VirtualMachine.set_output(self())

  #   VirtualMachine.set_register(1, 'A')

  #   VirtualMachine.run()

  #   assert_receive "E"
  # end

  test "outputting 'A'" do
    VirtualMachine.load_program([19, ?A])
    VirtualMachine.set_output(self())
    VirtualMachine.run()
    assert_receive "A"
  end
end
