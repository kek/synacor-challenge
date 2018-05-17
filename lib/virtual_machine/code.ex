defmodule VirtualMachine.Code do
  def read(file) do
    file
    |> File.read!()
    |> to_codes
  end

  defp to_codes(<<a, b>> <> rest) do
    code = a + b * 256
    [code] ++ to_codes(rest)
  end

  defp to_codes(<<>>) do
    []
  end

  def parse([]), do: {}
  # halt: 0 - stop execution and terminate the program
  def parse([0 | _]), do: {:halt}
  # set: 1 a b - set register <a> to the value of <b>
  def parse([1, a, b | _]), do: {:set, a, b}
  # push: 2 a - push <a> onto the stack
  def parse([2, a | _]), do: {:push, a}
  # pop: 3 a - remove the top element from the stack and write it into <a>; empty stack = error
  def parse([3, a | _]), do: {:pop, a}
  # eq: 4 a b c - set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
  def parse([4, a, b, c | _]), do: {:eq, a, b, c}
  # gt: 5 a b c - set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
  def parse([5, a, b, c | _]), do: {:gt, a, b, c}
  # jmp: 6 a - jump to <a>
  def parse([6, a | _]), do: {:jmp, a}
  # jt: 7 a b - if <a> is nonzero, jump to <b>
  def parse([7, a, b | _]), do: {:jt, a, b}
  # jf: 8 a b - if <a> is zero, jump to <b>
  def parse([8, a, b | _]), do: {:jf, a, b}
  # add: 9 a b c - assign into <a> the sum of <b> and <c> (modulo 32768)
  def parse([9, a, b, c | _]), do: {:add, a, b, c}
  # mult: 10 a b c - store into <a> the product of <b> and <c> (modulo 32768)
  def parse([10, a, b, c | _]), do: {:mult, a, b, c}
  # mod: 11 a b c - store into <a> the remainder of <b> divided by <c>
  def parse([11, a, b, c | _]), do: {:mod, a, b, c}
  # and: 12 a b c - stores into <a> the bitwise and of <b> and <c>
  def parse([12, a, b, c | _]), do: {:and, a, b, c}
  # or: 13 a b c - stores into <a> the bitwise or of <b> and <c>
  def parse([13, a, b, c | _]), do: {:or, a, b, c}
  # not: 14 a b - stores 15-bit bitwise inverse of <b> in <a>
  def parse([14, a, b | _]), do: {:not, a, b}
  # rmem: 15 a b - read memory at address <b> and write it to <a>
  def parse([15, a, b | _]), do: {:rmem, a, b}
  # wmem: 16 a b - write the value from <b> into memory at address <a>
  def parse([16, a, b | _]), do: {:wmem, a, b}
  # call: 17 a - write the address of the next instruction to the stack and jump to <a>
  def parse([17, a | _]), do: {:call, a}
  # ret: 18 - remove the top element from the stack and jump to it; empty stack = halt
  def parse([18 | _]), do: {:ret}
  # out: 19 a - write the character represented by ascii code <a> to the terminal
  def parse([19, a | _]), do: {:out, a}
  # in: 20 a - read a character from the terminal and write its ascii code to <a>;
  #     it can be assumed that once input starts, it will continue until a newline is
  #     encountered; this means that you can safely read whole lines from the keyboard
  #     and trust that they will be fully read
  def parse([20, a | _]), do: {:in, a}
  # noop: 21 - no operation
  def parse([21 | _]), do: {:noop}
end
