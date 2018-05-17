defmodule Mix.Tasks.Debug do
  use Mix.Task

  @shortdoc "Debug the VM"

  def run(_) do
    Application.ensure_all_started(:virtual_machine)

    {:ok, pid} = VirtualMachine.UI.start_link()
    VirtualMachine.set_output(VirtualMachine.UI)

    "priv/challenge.bin"
    |> VirtualMachine.Code.read()
    |> VirtualMachine.load_program()

    Process.monitor(pid)

    receive do
      {:DOWN, _, _, _, _} -> true
    end
  end
end
