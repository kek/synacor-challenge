defmodule VirtualMachineTest do
  use ExUnit.Case
  doctest VirtualMachine

  test "greets the world" do
    assert VirtualMachine.hello() == :world
  end
end
