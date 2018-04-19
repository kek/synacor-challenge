defmodule VirtualMachine.Program do
  alias VirtualMachine.Instruction

  def evaluate(program, state) do
    instruction = Enum.at(program, state.pc)

    case instruction do
      nil ->
        state

      # halt: 0 - stop execution and terminate the program
      {:halt} ->
        state

      instruction ->
        state = Instruction.execute(instruction, state)
        state = %{state | pc: state.pc + 1}
        evaluate(program, state)
    end
  end
end
