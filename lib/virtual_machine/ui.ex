defmodule VirtualMachine.UI do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defstruct help: nil,
            output: nil,
            memory: nil,
            registers: nil,
            stack: nil,
            foo: nil,
            buffer: ""

  def init([]) do
    ExNcurses.initscr("")
    ExNcurses.clear()
    ExNcurses.refresh()

    ui = %__MODULE__{
      foo: new_window("foo", 10, 40, 0, 0),
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

  def print(window, text) do
    GenServer.call(__MODULE__, {:print, window, text})
  end

  def handle_call({:print, window_name, text}, _, ui) do
    window = Map.get(ui, window_name)
    ExNcurses.waddstr(window, text)
    ExNcurses.wrefresh(window)
    {:reply, :ok, ui}
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

  def handle_info({:ex_ncurses, :key, key}, ui) do
    string = "#{key} "
    ExNcurses.waddstr(ui.output, string)
    ExNcurses.wrefresh(ui.output)
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
    ExNcurses.wborder(window)
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
