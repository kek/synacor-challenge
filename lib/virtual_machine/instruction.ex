defmodule VirtualMachine.Instruction do
  alias VirtualMachine.Value

  # set: 1 a b - set register <a> to the value of <b>
  def execute({:set, destination, source}, state) do
    new_registers = Map.put(state.registers, destination, Value.dereference(source, state))
    %{state | registers: new_registers}
  end

  # push: 2 a - push <a> onto the stack
  def execute({:push, a}, state) do
    %{state | stack: [Value.dereference(a, state) | state.stack]}
  end

  # pop: 3 a - remove the top element from the stack and write it into <a>; empty stack = error
  # eq: 4 a b c - set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
  # gt: 5 a b c - set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
  # jmp: 6 a - jump to <a>
  # jt: 7 a b - if <a> is nonzero, jump to <b>
  # jf: 8 a b - if <a> is zero, jump to <b>
  # add: 9 a b c - assign into <a> the sum of <b> and <c> (modulo 32768)
  def execute({:add, dest, left, right}, state) do
    sum = Value.dereference(left, state) + Value.dereference(right, state)
    %{state | registers: Map.put(state.registers, dest, sum)}
  end

  # mult: 10 a b c - store into <a> the product of <b> and <c> (modulo 32768)
  # mod: 11 a b c - store into <a> the remainder of <b> divided by <c>
  # and: 12 a b c - stores into <a> the bitwise and of <b> and <c>
  # or: 13 a b c - stores into <a> the bitwise or of <b> and <c>
  # not: 14 a b - stores 15-bit bitwise inverse of <b> in <a>
  # rmem: 15 a b - read memory at address <b> and write it to <a>
  # wmem: 16 a b - write the value from <b> into memory at address <a>
  # call: 17 a - write the address of the next instruction to the stack and jump to <a>
  # ret: 18 - remove the top element from the stack and jump to it; empty stack = halt
  # out: 19 a - write the character represented by ascii code <a> to the terminal
  def execute({:out, value}, state) do
    send(state.output, Value.dereference(value, state))
    state
  end

  # in: 20 a - read a character from the terminal and write its ascii code to <a>;
  #     it can be assumed that once input starts, it will continue until a newline is
  #     encountered; this means that you can safely read whole lines from the keyboard
  #     and trust that they will be fully read
  # noop: 21 - no operation
end
