defmodule VirtualMachine.UI do
  alias VirtualMachine.{Code, Instruction}
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defstruct help: nil,
            output: nil,
            memory: nil,
            registers: nil,
            stack: nil,
            instruction: nil,
            buffer: ""

  def init([]) do
    ExNcurses.initscr("")
    ExNcurses.clear()
    ExNcurses.refresh()

    ui = %__MODULE__{
      instruction: new_window("foo", 10, 40, 0, 0),
      help: new_window("help", 4, 80, 20, 0),
      output: new_window("output", 10, 40, 10, 0),
      memory: new_window("memory", 20, 18, 0, 41),
      registers: new_window("registers", 10, 20, 0, 60),
      stack: new_window("stack", 10, 20, 10, 60)
    }

    ExNcurses.noecho()
    ExNcurses.curs_set(0)
    ExNcurses.listen()

    print_help_text(ui)

    {:ok, ui}
  end

  def display(window, map) when is_map(map) do
    ExNcurses.wclear(window)
    ExNcurses.wmove(window, 1, 0)

    Enum.each(map, fn {key, value} ->
      ExNcurses.waddstr(window, "#{key} => #{value}\n")
    end)

    ExNcurses.wrefresh(window)
    ExNcurses.refresh()
  end

  def display(window, tuple) when is_tuple(tuple) do
    ExNcurses.wclear(window)
    ExNcurses.waddstr(window, inspect(tuple))
    ExNcurses.wrefresh(window)
    ExNcurses.refresh()
  end

  def display(window, list, offset \\ 0) when is_list(list) do
    ExNcurses.wclear(window)

    list
    |> Enum.zip(0..length(list))
    |> Enum.each(fn {element, index} ->
      ExNcurses.waddstr(window, "#{offset + index}: #{element}\n")
    end)

    ExNcurses.wrefresh(window)
    ExNcurses.refresh()
  end

  def handle_call({:buffer}, _, ui) do
    {:reply, ui.buffer, ui}
  end

  def handle_info({:ex_ncurses, :key, ?q}, ui) do
    ExNcurses.clear()
    ExNcurses.refresh()
    ExNcurses.curs_set(1)
    ExNcurses.endwin()

    IO.puts("Goodbye!")
    {:stop, :STOP, ui}
  end

  def handle_info({:ex_ncurses, :key, ?s}, ui) do
    VirtualMachine.step()
    {:noreply, ui}
  end

  def handle_info({:ex_ncurses, :key, key}, ui) do
    string = "#{key} "
    ExNcurses.waddstr(ui.output, string)
    ExNcurses.wrefresh(ui.output)
    {:noreply, ui}
  end

  def handle_info({:state, state}, ui) do
    display(ui.registers, state.registers)
    display(ui.stack, state.stack)

    displayed_memory =
      state.memory
      |> Enum.drop(state.pc)
      |> Enum.take(10)

    display(ui.memory, displayed_memory, state.pc)

    code = Enum.drop(state.memory, state.pc)
    instruction = Code.parse(code)
    display(ui.instruction, instruction)
    {:noreply, ui}
  end

  def handle_info(10, ui) do
    ExNcurses.waddstr(ui.output, ui.buffer)
    ExNcurses.waddstr(ui.output, "\n")
    ExNcurses.wrefresh(ui.output)
    {:noreply, %{ui | buffer: ""}}
  end

  def handle_info(character, ui) do
    {:noreply, %{ui | buffer: ui.buffer <> List.to_string([character])}}
  end

  defp new_window(title, height, width, y, x) do
    window = ExNcurses.newwin(height, width, y, x)
    # ExNcurses.wborder(window)
    ExNcurses.wmove(window, 0, 2)
    ExNcurses.waddstr(window, title)
    ExNcurses.wmove(window, 1, 2)
    ExNcurses.wrefresh(window)

    window
  end

  defp print_help_text(ui) do
    ExNcurses.wmove(ui.help, 1, 2)
    ExNcurses.waddstr(ui.help, "q: Quit  s: Step  c: Continue")
    ExNcurses.wrefresh(ui.help)
    ui
  end
end
