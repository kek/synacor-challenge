defmodule VirtualMachine.InstructionTest do
  use ExUnit.Case
  import ExUnit.Assertions
  import VirtualMachine.Instruction
  alias VirtualMachine.State

  @offset 32768
  @memory_size 10

  describe "{:set, a, b}" do
    test "set register <a> to the value of <b>" do
      initial_state = %State{registers: %{@offset => 1}}

      expected_state = %State{
        registers: %{@offset => 1, (@offset + 1) => 1}
      }

      assert execute(initial_state, {:set, @offset + 1, @offset}) == expected_state
    end
  end

  describe "{:push, a}" do
    test "push <a> onto the stack" do
      initial_state = %State{registers: %{@offset => 2}, stack: [1]}
      expected_state = %State{registers: %{@offset => 2}, stack: [2, 1]}

      assert execute(initial_state, {:push, @offset}) == expected_state
    end
  end

  describe "{:pop, a}" do
    test "remove the top element from the stack and write it into <a>" do
      initial_state = %State{registers: %{@offset => 1}, stack: [2, 1]}
      expected_state = %State{registers: %{@offset => 2}, stack: [1]}

      assert execute(initial_state, {:pop, @offset}) == expected_state
    end

    test "empty stack = error" do
      initial_state = %State{stack: []}

      assert_raise(VirtualMachine.Exceptions.StackIsEmptyError, fn ->
        execute(initial_state, {:pop, @offset})
      end)
    end
  end

  describe "{:eq, a, b, c}" do
    test "set <a> to 1 if <b> is equal to <c>" do
      initial_state = %State{registers: %{(@offset + 1) => ?A, (@offset + 2) => ?A}}

      expected_state = %State{
        registers: %{@offset => 1, (@offset + 1) => ?A, (@offset + 2) => ?A}
      }

      assert execute(initial_state, {:eq, @offset, @offset + 1, @offset + 2}) == expected_state
    end

    test "set it to 0 otherwise" do
      initial_state = %State{registers: %{(@offset + 1) => ?A, (@offset + 2) => ?B}}

      expected_state = %State{
        registers: %{@offset => 0, (@offset + 1) => ?A, (@offset + 2) => ?B}
      }

      assert execute(initial_state, {:eq, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:gt}" do
    test "set <a> to 1 if <b> is greater than <c>" do
      initial_state = %State{registers: %{(@offset + 1) => ?B, (@offset + 2) => ?A}}

      expected_state = %State{
        registers: %{@offset => 1, (@offset + 1) => ?B, (@offset + 2) => ?A}
      }

      assert execute(initial_state, {:gt, @offset, @offset + 1, @offset + 2}) == expected_state
    end

    test "set it to 0 otherwise" do
      initial_state = %State{registers: %{(@offset + 1) => ?A, (@offset + 2) => ?A}}

      expected_state = %State{
        registers: %{@offset => 0, (@offset + 1) => ?A, (@offset + 2) => ?A}
      }

      assert execute(initial_state, {:gt, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:jmp, a}" do
    test "jump to <a>" do
      initial_state = %State{registers: %{@offset => 10}, pc: 0}
      expected_state = %State{registers: %{@offset => 10}, pc: 8}

      assert execute(initial_state, {:jmp, @offset}) == expected_state
    end
  end

  describe "{:jt, a, b}" do
    test "if <a> is nonzero, jump to <b>" do
      initial_state = %State{registers: %{@offset => 1}, pc: 0}
      expected_state = %State{registers: %{@offset => 1}, pc: 7}

      assert execute(initial_state, {:jt, @offset, 10}) == expected_state
    end

    test "otherwise noop" do
      initial_state = %State{registers: %{@offset => 0}, pc: 0}
      expected_state = %State{registers: %{@offset => 0}, pc: 0}

      assert execute(initial_state, {:jt, @offset, 10}) == expected_state
    end
  end

  describe "{:jf, a, b}" do
    test "if <a> is zero, jump to <b>" do
      initial_state = %State{registers: %{@offset => 0}, pc: 0}
      expected_state = %State{registers: %{@offset => 0}, pc: 7}

      assert execute(initial_state, {:jf, @offset, 10}) == expected_state
    end

    test "otherwise noop" do
      initial_state = %State{registers: %{@offset => 1}, pc: 0}
      expected_state = %State{registers: %{@offset => 1}, pc: 0}

      assert execute(initial_state, {:jf, @offset, 10}) == expected_state
    end
  end

  describe "{:add, a, b, c}" do
    test "assign into <a> the sum of <b> and <c> (modulo 32768)" do
      # all math is modulo 32768; 32758 + 15 => 5
      initial_state = %State{registers: %{(@offset + 1) => 32758, (@offset + 2) => 15}}

      expected_state = %State{
        registers: %{@offset => 5, (@offset + 1) => 32758, (@offset + 2) => 15}
      }

      assert execute(initial_state, {:add, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:mult, a, b, c}" do
    test "store into <a> the product of <b> and <c> (modulo 32768)" do
      initial_state = %State{registers: %{(@offset + 1) => 1000, (@offset + 2) => 100}}

      expected_state = %State{
        registers: %{@offset => 1696, (@offset + 1) => 1000, (@offset + 2) => 100}
      }

      assert execute(initial_state, {:mult, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:mod, a, b, c}" do
    test "store into <a> the remainder of <b> divided by <c>" do
      initial_state = %State{registers: %{(@offset + 1) => 1000, (@offset + 2) => 100}}

      expected_state = %State{
        registers: %{@offset => 0, (@offset + 1) => 1000, (@offset + 2) => 100}
      }

      assert execute(initial_state, {:mod, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:and, a, b, c}" do
    test "stores into <a> the bitwise and of <b> and <c>" do
      initial_state = %State{registers: %{(@offset + 1) => 1, (@offset + 2) => 1}}

      expected_state = %State{
        registers: %{@offset => 1, (@offset + 1) => 1, (@offset + 2) => 1}
      }

      assert execute(initial_state, {:and, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:or, a, b, c}" do
    test "stores into <a> the bitwise or of <b> and <c>" do
      initial_state = %State{registers: %{(@offset + 1) => 1, (@offset + 2) => 1}}

      expected_state = %State{
        registers: %{@offset => 1, (@offset + 1) => 1, (@offset + 2) => 1}
      }

      assert execute(initial_state, {:and, @offset, @offset + 1, @offset + 2}) == expected_state
    end
  end

  describe "{:not. a, b}" do
    test "stores 15-bit bitwise inverse of <b> in <a>" do
      initial_state = %State{registers: %{(@offset + 1) => 0}}

      expected_state = %State{
        registers: %{@offset => 32767, (@offset + 1) => 0}
      }

      assert execute(initial_state, {:not, @offset, @offset + 1}) == expected_state
    end
  end

  describe "{:rmem, a, b}" do
    test "read memory at address <b> and write it to <a> when <a> references a register" do
      x = @offset
      y = @offset + 1

      initial_state = %State{registers: %{x => 0}, memory: memory([?A])}

      expected_state = %State{
        registers: %{x => 0, y => ?A},
        memory: memory([?A])
      }

      assert execute(initial_state, {:rmem, y, x}) == expected_state
    end

    test "read memory at address <b> and write it to <a> when <a> references memory" do
      initial_state = %State{memory: memory([?A, ?B])}

      expected_state = %State{
        memory: memory([?B, ?B])
      }

      assert execute(initial_state, {:rmem, 0, 1}) == expected_state
    end
  end

  describe "{:wmem, a, b}" do
    test "write the value from <b> (reg) into memory at address <a> (mem)" do
      # do we have to allow b to be a register?
      x = @offset

      initial_state = %State{registers: %{x => ?B}, memory: memory([?A])}
      expected_state = %State{registers: %{x => ?B}, memory: memory([?B])}
      assert execute(initial_state, {:wmem, 0, x}) == expected_state
    end

    test "copy a register value to another register" do
      x = @offset
      y = @offset + 1
      initial_state = %State{registers: %{x => ?A, y => ?B}}
      expected_state = %State{registers: %{x => ?B, y => ?B}}
      assert execute(initial_state, {:wmem, x, y}) == expected_state
    end

    test "write a literal value <b> into memory" do
      initial_state = %State{registers: %{}, memory: memory([?A, ?B])}
      expected_state = %State{registers: %{}, memory: memory([?B, ?B])}
      assert execute(initial_state, {:wmem, 0, ?B}) == expected_state
    end

    test "write a literal value <b> into the memory address referenced by register <a>" do
      initial_state = %State{registers: %{@offset => 0}, memory: memory([?A])}
      expected_state = %State{registers: %{@offset => 0}, memory: memory([?B])}
      assert execute(initial_state, {:wmem, @offset, ?B}) == expected_state
    end
  end

  test "wmem, then rmem" do
    x = @offset
    z = @offset + 2

    initial_state = %State{
      registers: %{x => 0},
      memory: memory()
    }

    expected_state = %State{
      registers: %{x => 0, z => ?B},
      memory: memory([?B])
    }

    actual_state =
      initial_state
      |> execute({:wmem, 0, ?B})
      |> execute({:rmem, z, x})

    assert actual_state == expected_state
  end

  describe "{:call, a}" do
    test "write the address of the next instruction to the stack and jump to <a>" do
      initial_state = %State{registers: %{@offset => 10}, pc: 0}
      expected_state = %State{registers: %{@offset => 10}, pc: 8, stack: [2]}
      assert execute(initial_state, {:call, @offset}) == expected_state
    end
  end

  describe "{:ret}" do
    test "remove the top element from the stack and jump to it" do
      initial_state = %State{pc: 0, stack: [10]}
      expected_state = %State{pc: 9, stack: []}
      assert execute(initial_state, {:ret}) == expected_state
    end

    test "empty stack = halt" do
      initial_state = %State{pc: 0, stack: []}

      assert_raise VirtualMachine.Exceptions.StackIsEmptyError, fn ->
        execute(initial_state, {:ret})
      end
    end
  end

  describe "{:out, a}" do
    test "write the character represented by ascii code <a> to the terminal" do
    end
  end

  describe "{:in, a}" do
    test "read a character from the terminal and write its ascii code to <a>" do
      # it can be assumed that once input starts, it will continue until a newline is
      # encountered; this means that you can safely read whole lines from the keyboard
      # and trust that they will be fully read
    end
  end

  describe "{:noop}" do
    test "no operation" do
      state = %State{}
      assert execute(state, {:noop}) == state
    end
  end

  defp memory(start \\ []) do
    rest =
      Stream.cycle([0])
      |> Enum.take(@memory_size - length(start))

    start ++ rest
  end
end
