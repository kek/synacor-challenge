defmodule Mix.Tasks.Challenge do
  use Mix.Task

  @shortdoc "Run the challenge program"

  def run(_) do
    Application.ensure_all_started(:virtual_machine)
    VirtualMachine.challenge()
    VirtualMachine.print_state()
  end
end
