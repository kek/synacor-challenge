defmodule VirtualMachine.State do
  defstruct registers: %{},
            program: [],
            output: nil,
            stack: []
end
