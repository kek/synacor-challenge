defmodule VirtualMachine.State do
  defstruct registers: %{},
            memory: [],
            output: VirtualMachine.Terminal,
            stack: [],
            pc: 0
end
