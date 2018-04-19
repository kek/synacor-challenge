defmodule VirtualMachine do
  @moduledoc """
  Virtual machine capable of running Syncore code.
  """

  use GenServer
  alias VirtualMachine.{Bytecode, Program, State, Terminal}

  @register_offset 32768

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]), do: {:ok, %State{}}

  def set_register(register, value),
    do: GenServer.call(__MODULE__, {:set_register, @register_offset + register, value})

  def get_register(register),
    do: GenServer.call(__MODULE__, {:get_register, @register_offset + register})

  def set_output(pid), do: GenServer.call(__MODULE__, {:set_output, pid})

  def load_bytecode(bytecode), do: load_program(Bytecode.parse(bytecode))

  def load_program(program), do: GenServer.call(__MODULE__, {:load_program, program})

  def run, do: GenServer.call(__MODULE__, {:run})

  def challenge do
    set_output(Terminal)

    "priv/challenge.bin"
    |> Bytecode.read()
    |> load_bytecode()

    run()
  end

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
    new_state = %{state | program: program}
    {:reply, :ok, new_state}
  end

  def handle_call({:run}, _, state) do
    new_state = Program.evaluate(state.program, state)

    {:reply, :ok, new_state}
  end
end
