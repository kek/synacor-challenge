defmodule VirtualMachine.State do
  defstruct registers: %{},
            memory: [],
            output: nil,
            stack: [],
            pc: 0
end
