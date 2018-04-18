defmodule VirtualMachine do
  @moduledoc """
  Virtual machine capable of running Syncore code.
  """

  use GenServer
  require Logger
  alias VirtualMachine.Bytecode

  @register_offset 32768

  defstruct registers: %{},
            program: [],
            output: nil

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]), do: {:ok, %__MODULE__{}}

  def set_register(register, value),
    do: GenServer.call(__MODULE__, {:set_register, @register_offset + register, value})

  def get_register(register),
    do: GenServer.call(__MODULE__, {:get_register, @register_offset + register})

  def set_output(pid), do: GenServer.call(__MODULE__, {:set_output, pid})

  def load_bytecode(bytecode), do: load_program(Bytecode.parse(bytecode))

  def load_program(program), do: GenServer.call(__MODULE__, {:load_program, program})

  def run, do: GenServer.call(__MODULE__, {:run})

  def handle_call({:set_output, pid}, _, state) do
    new_state = %{state | output: pid}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_register, register, value}, _, state) do
    new_state = %{state | registers: Map.put(state.registers, register, value)}
    {:reply, :ok, new_state}
  end

  def handle_call({:get_register, register}, _, state) do
    value = Map.get(state.registers, register)
    {:reply, value, state}
  end

  def handle_call({:load_program, bytecode}, _, state) do
    program = Bytecode.parse(bytecode)
    Logger.debug("Loaded program: #{inspect(program)}")
    new_state = %{state | program: program}
    {:reply, :ok, new_state}
  end

  def handle_call({:run}, _, state) do
    new_state = evaluate(state.program, state)

    {:reply, :ok, new_state}
  end

  defp evaluate([], state), do: state

  # halt: 0 - stop execution and terminate the program
  defp evaluate([{:halt} | _], state) do
    state
  end

  # set: 1 a b - set register <a> to the value of <b>
  defp evaluate([{:set, destination, source} | rest], state) do
    new_registers = Map.put(state.registers, destination, dereference(source, state))
    new_state = %{state | registers: new_registers}

    evaluate(rest, new_state)
  end

  # push: 2 a - push <a> onto the stack
  # pop: 3 a - remove the top element from the stack and write it into <a>; empty stack = error
  # eq: 4 a b c - set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
  # gt: 5 a b c - set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
  # jmp: 6 a - jump to <a>
  # jt: 7 a b - if <a> is nonzero, jump to <b>
  # jf: 8 a b - if <a> is zero, jump to <b>
  # add: 9 a b c - assign into <a> the sum of <b> and <c> (modulo 32768)
  defp evaluate([{:add, dest, left, right} | rest], state) do
    Logger.debug("left: #{dereference(left, state)}")
    Logger.debug("right: #{dereference(right, state)}")
    sum = dereference(left, state) + dereference(right, state)
    new_state = %{state | registers: Map.put(state.registers, dest, sum)}

    evaluate(rest, new_state)
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
  defp evaluate([{:out, value} | rest], state) do
    send(state.output, dereference(value, state))

    evaluate(rest, state)
  end

  # in: 20 a - read a character from the terminal and write its ascii code to <a>;
  #     it can be assumed that once input starts, it will continue until a newline is
  #     encountered; this means that you can safely read whole lines from the keyboard
  #     and trust that they will be fully read
  # noop: 21 - no operation

  # numbers 0..32767 mean a literal value
  defp dereference(value, _state) when value >= 0 and value < @register_offset, do: value

  # numbers 32768..32775 instead mean registers 0..7
  defp dereference(value, state)
       when value >= @register_offset and value < @register_offset + 8 do
    Map.get(state.registers, value)
  end

  defp dereference(value, state) do
    raise VirtualMachine.Exceptions.InvalidRegisterError,
      message: "Invalid value #{value}. State: #{inspect(state)}"
  end
end
