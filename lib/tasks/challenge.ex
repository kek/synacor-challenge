defmodule Mix.Tasks.Challenge do
  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:virtual_machine)
    VirtualMachine.challenge()
  end
end
