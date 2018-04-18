defmodule VirtualMachine.Value do
  @register_offset 32768

  # numbers 0..32767 mean a literal value
  def dereference(value, _state) when value >= 0 and value < @register_offset, do: value

  # numbers 32768..32775 instead mean registers 0..7
  def dereference(value, state)
      when value >= @register_offset and value < @register_offset + 8 do
    Map.get(state.registers, value)
  end

  def dereference(value, state) do
    raise VirtualMachine.Exceptions.InvalidRegisterError,
      message: "Invalid value #{value}. State: #{inspect(state)}"
  end
end
