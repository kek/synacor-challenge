defmodule VirtualMachine.Terminal do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]), do: {:ok, ""}

  def buffer do
    GenServer.call(__MODULE__, {:buffer})
  end

  def handle_call({:buffer}, _, buffer) do
    {:reply, buffer, buffer}
  end

  def handle_info({:state, _}, buffer) do
    {:noreply, buffer}
  end

  def handle_info(10, buffer) do
    IO.puts(buffer)
    {:noreply, ""}
  end

  def handle_info(character, buffer) do
    {:noreply, buffer <> List.to_string([character])}
  end
end
