# defmodule VirtualMachine.Program do
#   alias VirtualMachine.{Instruction, Code}

#   def evaluate(program, state) do
#     code = Enum.drop(program, state.pc)

#     case code do
#       [] ->
#         state

#       # halt: 0 - stop execution and terminate the program
#       [0 | _] ->
#         state

#       code ->
#         instruction = Code.parse(code)
#         state = Instruction.execute(state, instruction)
#         state = %{state | pc: state.pc + tuple_size(instruction)}
#         evaluate(program, state)
#     end
#   end
# end
