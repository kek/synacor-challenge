defmodule VirtualMachine do
  @moduledoc """
  Virtual machine capable of running Syncore code.
  """

  use GenServer

  alias VirtualMachine.Bytecode

  defstruct registers: %{},
            program: [],
            output: nil

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]), do: {:ok, %__MODULE__{}}

  def set_register(register, value),
    do: GenServer.call(__MODULE__, {:set_register, register, value})

  def get_register(register), do: GenServer.call(__MODULE__, {:get_register, register})

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
    new_state = %{state | program: program}
    {:reply, :ok, new_state}
  end

  def handle_call({:run}, _, state) do
    new_state = evaluate(state.program, state)

    {:reply, :ok, new_state}
  end

  def evaluate([{:out, value} | rest], state) do
    text = [dereference(value, state)] |> List.to_string()
    send(state.output, text)
    evaluate(rest, state)
  end

  def evaluate([{:halt} | _], state) do
    state
  end

  def evaluate([], state), do: state

  # numbers 0..32767 mean a literal value
  defp dereference(value, _state) when value >= 0 and value <= 32767, do: value

  # numbers 32768..32775 instead mean registers 0..7
  defp dereference(value, state) when value >= 32768 and value <= 32775 do
    Map.get(state.registers, value - 32768)
  end

  defp dereference(value, state) do
    raise VirtualMachine.Exceptions.InvalidRegisterError,
      message: "Invalid value #{value}. State: #{inspect(state)}"
  end
end
