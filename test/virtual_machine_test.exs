defmodule VirtualMachineTest do
  use ExUnit.Case
  doctest VirtualMachine

  import VirtualMachine

  setup do
    VirtualMachine.reset()
    :ok
  end

  test "running the example program outputs the character in register 0 incremented by 4" do
    program = [9, 32768, 32769, 4, 19, 32768]
    load_bytecode(program)
    set_output(self())
    set_register(1, ?A)
    run()

    assert_receive ?E
  end

  test "resetting the machine clears the state" do
    load_program([{:out, ?A}])
    set_output(self())
    run()
    assert_receive ?A

    run()
    refute_receive ?A
  end

  test "loading bytecode" do
    load_bytecode([19, ?A])
    set_output(self())
    run()
    assert_receive ?A
  end

  test "outputting 'A'" do
    load_program([{:out, ?A}])
    set_output(self())
    run()
    assert_receive ?A
  end

  test "outputting value of register 0" do
    set_register(0, ?A)
    load_program([{:out, 32768}])
    set_output(self())
    run()
    assert_receive ?A
  end

  test "getting and setting registers" do
    Enum.each(0..7, &set_register(&1, 1))
    Enum.each(0..7, &assert(get_register(&1) == 1))
  end

  describe "{:halt}" do
    test "stop execution and terminate the program" do
      load_program([{:halt}, {:out, ?A}])
      set_output(self())
      run()
      refute_receive ?A
    end
  end
end
