defmodule VirtualMachine.Program do
  alias VirtualMachine.{Instruction, Bytecode}

  def evaluate(program, state) do
    code = Enum.drop(program, state.pc)

    case code do
      [] ->
        state

      # halt: 0 - stop execution and terminate the program
      {:halt} ->
        state

      code ->
        instruction = Bytecode.parse(code)
        state = Instruction.execute(instruction, state)
        state = %{state | pc: state.pc}
        evaluate(program, state)
    end
  end
end
