defmodule Mix.Tasks.Ui do
  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:virtual_machine)
    VirtualMachine.UI.run()
  end
end
