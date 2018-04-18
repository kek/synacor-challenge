defmodule VirtualMachine.Program do
  alias VirtualMachine.Instruction

  def evaluate([], state), do: state

  # halt: 0 - stop execution and terminate the program
  def evaluate([{:halt} | _], state) do
    state
  end

  def evaluate([instruction | rest], state) do
    new_state = Instruction.execute(instruction, state)
    evaluate(rest, new_state)
  end
end
