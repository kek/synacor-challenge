defmodule VirtualMachine do
  @moduledoc """
  Virtual machine capable of running Syncore code.
  """

  use GenServer

  defstruct registers: %{},
            program: [],
            output: nil

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]), do: {:ok, %__MODULE__{}}

  def set_register(register, value),
    do: GenServer.call(__MODULE__, {:set_register, register, value})

  def set_output(pid), do: GenServer.call(__MODULE__, {:set_output, pid})

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

  def handle_call({:load_program, program}, _, state) do
    new_state = %{state | program: program}
    {:reply, :ok, new_state}
  end

  def handle_call({:run}, _, state) do
    new_state = evaluate(state.program, state)

    {:reply, :ok, new_state}
  end

  def evaluate([19 | [character | rest]], state) do
    text = [character] |> List.to_string()
    send(state.output, text)
    evaluate(rest, state)
  end

  def evaluate([], state), do: state
end
