defmodule VirtualMachine.State do
  @emptymemory Enum.map(0..32767, fn _ -> 0 end)
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
            pc: 0
end
