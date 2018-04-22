defmodule VirtualMachine.UI do
  defstruct help: nil,
            output: nil,
            memory: nil,
            registers: nil,
            stack: nil

  def run do
    setup()
    |> print_help_text()
    |> loop()
    |> cleanup()
  end

  defp loop(ui) do
    receive do
      {:ex_ncurses, :key, ?q} ->
        ExNcurses.clear()
        ExNcurses.addstr("Goodbye!")
        ExNcurses.refresh()

      {:ex_ncurses, :key, key} ->
        string = [key] |> List.to_string()
        ExNcurses.waddstr(ui.output, string)
        ExNcurses.wrefresh(ui.output)
        loop(ui)
    end
  end

  defp setup() do
    ExNcurses.initscr("")
    ExNcurses.clear()
    ExNcurses.refresh()

    ui = %__MODULE__{
      help: new_window("help", 10, 40, 0, 0),
      output: new_window("output", 10, 40, 10, 0),
      memory: new_window("memory", 20, 18, 0, 41),
      registers: new_window("registers", 10, 20, 0, 60),
      stack: new_window("stack", 10, 20, 10, 60)
    }

    ExNcurses.noecho()
    ExNcurses.curs_set(0)
    ExNcurses.listen()

    ui
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
    ExNcurses.waddstr(ui.help, "q: Quit")
    ExNcurses.wrefresh(ui.help)
    ui
  end

  defp cleanup(ui) do
    ExNcurses.curs_set(1)
    ExNcurses.endwin()
    ui
  end
end
