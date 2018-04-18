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

  test "outputting value of register 0" do
    VirtualMachine.set_register(0, ?A)
    VirtualMachine.load_program([19, 32768])
    VirtualMachine.set_output(self())
    VirtualMachine.run()
    assert_receive "A"
  end

  test "getting and setting registers" do
    VirtualMachine.set_register(0, 1)
    VirtualMachine.set_register(1, 1)
    VirtualMachine.set_register(2, 1)
    VirtualMachine.set_register(3, 1)
    VirtualMachine.set_register(4, 1)
    VirtualMachine.set_register(5, 1)
    VirtualMachine.set_register(6, 1)
    VirtualMachine.set_register(7, 1)
    assert VirtualMachine.get_register(0) == 1
    assert VirtualMachine.get_register(1) == 1
    assert VirtualMachine.get_register(2) == 1
    assert VirtualMachine.get_register(3) == 1
    assert VirtualMachine.get_register(4) == 1
    assert VirtualMachine.get_register(5) == 1
    assert VirtualMachine.get_register(6) == 1
    assert VirtualMachine.get_register(7) == 1
  end

  test "stopping the program" do
    VirtualMachine.load_program([0, 19, ?A])
    VirtualMachine.set_output(self())
    VirtualMachine.run()
    refute_receive "A"
  end
end
