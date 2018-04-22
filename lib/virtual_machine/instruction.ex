defmodule VirtualMachine.Instruction do
  alias VirtualMachine.{Value, Exceptions}
  require Bitwise

  @type instruction :: Tuple.t()
  @type state :: VirtualMachine.State.t()
  @spec execute(instruction :: instruction(), state :: state()) :: state()

  # set: 1 a b - set register <a> to the value of <b>
  def execute(state, {:set, destination, source}) do
    new_registers = Map.put(state.registers, destination, Value.dereference(source, state))
    %{state | registers: new_registers}
  end

  # push: 2 a - push <a> onto the stack
  def execute(state, {:push, a}) do
    %{state | stack: [Value.dereference(a, state) | state.stack]}
  end

  # pop: 3 a - remove the top element from the stack and write it into <a>
  def execute(state = %{stack: [h | t]}, {:pop, dest}) do
    new_registers = Map.put(state.registers, dest, h)
    %{state | stack: t, registers: new_registers}
  end

  # empty stack = error
  def execute(%{stack: []}, {:pop, _}) do
    raise Exceptions.StackIsEmptyError, message: "Tried to pop empty stack"
  end

  # eq: 4 a b c - set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
  def execute(state, {:eq, dest, left, right}) do
    values = {Value.dereference(left, state), Value.dereference(right, state)}

    result =
      case values do
        {x, x} -> 1
        {_, _} -> 0
      end

    new_registers = Map.put(state.registers, dest, result)
    %{state | registers: new_registers}
  end

  # gt: 5 a b c - set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
  def execute(state, {:gt, dest, left, right}) do
    result = if Value.dereference(left, state) > Value.dereference(right, state), do: 1, else: 0

    new_registers = Map.put(state.registers, dest, result)
    %{state | registers: new_registers}
  end

  # jmp: 6 a - jump to <a>
  def execute(state, {:jmp, dest}) do
    %{state | pc: Value.dereference(dest, state) - 2}
  end

  # jt: 7 a b - if <a> is nonzero, jump to <b>
  def execute(state, {:jt, a, dest}) do
    if(Value.dereference(a, state) != 0) do
      %{state | pc: Value.dereference(dest, state) - 3}
    else
      state
    end
  end

  # jf: 8 a b - if <a> is zero, jump to <b>
  def execute(state, {:jf, a, dest}) do
    if(Value.dereference(a, state) == 0) do
      %{state | pc: Value.dereference(dest, state) - 3}
    else
      state
    end
  end

  # add: 9 a b c - assign into <a> the sum of <b> and <c> (modulo 32768)
  def execute(state, {:add, dest, left, right}) do
    sum = modulo32768(Value.dereference(left, state) + Value.dereference(right, state))
    # TODO: dereference dest?
    %{state | registers: Map.put(state.registers, dest, sum)}
  end

  # mult: 10 a b c - store into <a> the product of <b> and <c> (modulo 32768)
  def execute(state, {:mult, a, b, c}) do
    b = Value.dereference(b, state)
    c = Value.dereference(c, state)
    product = b * c
    product = modulo32768(product)
    %{state | registers: Map.put(state.registers, a, product)}
  end

  # mod: 11 a b c - store into <a> the remainder of <b> divided by <c>
  def execute(state, {:mod, a, b, c}) do
    b = Value.dereference(b, state)
    c = Value.dereference(c, state)
    remainder = rem(b, c)
    # not tested:
    remainder = modulo32768(remainder)
    %{state | registers: Map.put(state.registers, a, remainder)}
  end

  # and: 12 a b c - stores into <a> the bitwise and of <b> and <c>
  def execute(state, {:and, a, b, c}) do
    b = Value.dereference(b, state)
    c = Value.dereference(c, state)

    %{state | registers: Map.put(state.registers, a, Bitwise.band(b, c))}
  end

  # or: 13 a b c - stores into <a> the bitwise or of <b> and <c>
  def execute(state, {:or, a, b, c}) do
    b = Value.dereference(b, state)
    c = Value.dereference(c, state)

    %{state | registers: Map.put(state.registers, a, Bitwise.bor(b, c))}
  end

  # not: 14 a b - stores 15-bit bitwise inverse of <b> in <a>
  def execute(state, {:not, a, b}) do
    b = Value.dereference(b, state)

    %{state | registers: Map.put(state.registers, a, modulo32768(Bitwise.bnot(b)))}
  end

  # rmem: 15 a b - read memory at address <b> and write it to <a>
  def execute(state, {:rmem, a, b}) do
    b = Value.dereference(b, state)
    value = Enum.at(state.memory, b)

    update(state, a, value)
  end

  # wmem: 16 a b - write the value from <b> into memory at address <a>
  def execute(state, {:wmem, a, b}) when b < 32768 do
    a = Value.dereference(a, state)
    b = Value.dereference(b, state)

    update(state, a, b)
  end

  def execute(state, {:wmem, a, b}) do
    b = Value.dereference(b, state)

    update(state, a, b)
  end

  # call: 17 a - write the address of the next instruction to the stack and jump to <a>
  def execute(state, {:call, a}) do
    %{state | stack: [state.pc + 2], pc: Value.dereference(a, state) - 2}
  end

  # ret: 18 - remove the top element from the stack and jump to it; empty stack = halt
  # out: 19 a - write the character represented by ascii code <a> to the terminal
  def execute(state, {:out, value}) do
    send(state.output, Value.dereference(value, state))
    state
  end

  # in: 20 a - read a character from the terminal and write its ascii code to <a>;
  #     it can be assumed that once input starts, it will continue until a newline is
  #     encountered; this means that you can safely read whole lines from the keyboard
  #     and trust that they will be fully read
  # noop: 21 - no operation
  def execute(state, {:noop}), do: state

  defp modulo32768(number) when number < 0, do: number + 32768
  defp modulo32768(number) when number < 32768, do: number
  defp modulo32768(number), do: modulo32768(number - 32768)

  defp update(state, address, value) when address < 32768 do
    %{state | memory: List.replace_at(state.memory, address, value)}
  end

  defp update(state, address, value) do
    %{state | registers: Map.put(state.registers, address, value)}
  end
end
