defmodule VirtualMachine do
  @moduledoc """
  Virtual machine capable of running Syncore code.
  """

  use GenServer
  alias VirtualMachine.{Code, Program, State, Terminal, Instruction}

  @register_offset 32768

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]), do: {:ok, %State{memory: Enum.map(0..32767, fn _ -> 0 end)}}

  def set_register(register, value),
    do: GenServer.call(__MODULE__, {:set_register, @register_offset + register, value})

  def get_register(register),
    do: GenServer.call(__MODULE__, {:get_register, @register_offset + register})

  def set_output(pid), do: GenServer.call(__MODULE__, {:set_output, pid})

  def load_program(program), do: GenServer.call(__MODULE__, {:load_program, program})

  def run, do: GenServer.call(__MODULE__, {:run})

  def step, do: GenServer.call(__MODULE__, {:step})

  def reset, do: GenServer.call(__MODULE__, {:reset})

  def challenge do
    set_output(Terminal)

    "priv/challenge.bin"
    |> Code.read()
    |> load_program()

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
    new_state = %{state | memory: bytecode}
    send(state.output, {:state, new_state})

    {:reply, :ok, new_state}
  end

  def handle_call({:run}, _, state) do
    new_state = Program.evaluate(state.memory, state)

    {:reply, :ok, new_state}
  end

  def handle_call({:step}, _, state) do
    {:reply, :ok, step(state)}
  end

  def handle_call({:reset}, _, _) do
    {:reply, :ok, %State{memory: Enum.map(0..32767, fn _ -> 0 end)}}
  end

  defp step(state = %{pc: pc, memory: memory}) do
    code = Enum.drop(memory, pc)
    instruction = Code.parse(code)
    state = Instruction.execute(state, instruction)
    new_state = %{state | pc: state.pc + tuple_size(instruction)}
    send(state.output, {:state, new_state})
    new_state
  end
end
