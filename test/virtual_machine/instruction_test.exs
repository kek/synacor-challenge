defmodule VirtualMachine.InstructionTest do
  use ExUnit.Case

  import VirtualMachine.Instruction

  @offset 32768

  describe "{:set, a, b}" do
    test "set register <a> to the value of <b>" do
      initial_state = %{registers: %{@offset => 1}}

      expected_state = %{
        registers: %{@offset => 1, (@offset + 1) => 1}
      }

      assert execute({:set, @offset + 1, @offset}, initial_state) == expected_state
    end
  end

  describe "{:push, a}" do
    test "push <a> onto the stack" do
    end
  end

  describe "{:pop, a}" do
    test "remove the top element from the stack and write it into <a>; empty stack = error" do
    end
  end

  describe "{:eq, a, b, c}" do
    test "set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise" do
    end
  end

  describe "{:gt}" do
    test "set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise" do
    end
  end

  describe "{:jmp, a}" do
    test "jump to <a>" do
    end
  end

  describe "{:jt, a, b}" do
    test "if <a> is nonzero, jump to <b>" do
    end
  end

  describe "{:jf, a, b}" do
    test "if <a> is zero, jump to <b>" do
    end
  end

  describe "{:add, a, b, c}" do
    test "assign into <a> the sum of <b> and <c> (modulo 32768)" do
    end
  end

  describe "{:mult, a, b, c}" do
    test "store into <a> the product of <b> and <c> (modulo 32768)" do
    end
  end

  describe "{:mod, a, b, c}" do
    test "store into <a> the remainder of <b> divided by <c>" do
    end
  end

  describe "{:and, a, b, c}" do
    test "stores into <a> the bitwise and of <b> and <c>" do
    end
  end

  describe "{:or, a, b, c}" do
    test "stores into <a> the bitwise or of <b> and <c>" do
    end
  end

  describe "{:not. a, b}" do
    test "stores 15-bit bitwise inverse of <b> in <a>" do
    end
  end

  describe "{:rmem, a, b}" do
    test "read memory at address <b> and write it to <a>" do
    end
  end

  describe "{:wmem, a, b}" do
    test "write the value from <b> into memory at address <a>" do
    end
  end

  describe "{:call, a}" do
    test "write the address of the next instruction to the stack and jump to <a>" do
    end
  end

  describe "{:ret}" do
    test "remove the top element from the stack and jump to it; empty stack = halt" do
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
    end
  end
end
