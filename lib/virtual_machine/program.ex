defmodule VirtualMachine.Program do
  alias VirtualMachine.{Instruction, Bytecode}
  # require Logger

  def evaluate(program, state) do
    code = Enum.drop(program, state.pc)

    case code do
      [] ->
        state

      # halt: 0 - stop execution and terminate the program
      [0 | _] ->
        state

      code ->
        instruction = Bytecode.parse(code)
        # Logger.debug("Executing #{inspect(instruction)} with #{inspect(state)}")
        state = Instruction.execute(instruction, state)
        state = %{state | pc: state.pc + tuple_size(instruction)}
        evaluate(program, state)
    end
  end
end
