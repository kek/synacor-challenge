defmodule Mix.Tasks.Debug do
  use Mix.Task

  @moduledoc "Debug the VM"

  def run(_) do
    Application.ensure_all_started(:virtual_machine)

    {:ok, pid} = VirtualMachine.UI.start_link()
    VirtualMachine.set_output(VirtualMachine.UI)

    "priv/challenge.bin"
    |> VirtualMachine.Code.read()
    |> VirtualMachine.load_program()

    VirtualMachine.run()

    Process.monitor(pid)

    receive do
      {:DOWN, _, _, _, _} -> true
    end
  end
end
