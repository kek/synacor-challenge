defmodule VirtualMachine.State do
  defstruct registers: %{
              32768 => 0,
              32769 => 0,
              32770 => 0,
              32771 => 0,
              32772 => 0,
              32773 => 0,
              32774 => 0,
              32775 => 0
            },
            memory: [],
            output: VirtualMachine.Terminal,
            stack: [],
            pc: 0,
            running: {true, nil}
end
