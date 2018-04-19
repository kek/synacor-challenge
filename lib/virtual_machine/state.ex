defmodule VirtualMachine.State do
  defstruct registers: %{},
            program: [],
            output: nil,
            stack: [],
            pc: 0
end
