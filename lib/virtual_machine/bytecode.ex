defmodule VirtualMachine.Bytecode do
  def read(file) do
    file
    |> File.read!()
    |> to_bytes
  end

  def to_bytes(<<a, b>> <> rest) do
    [b * 16 + a] ++ to_bytes(rest)
  end

  def to_bytes(<<>>) do
    []
  end

  def parse([]), do: []

  # halt: 0 - stop execution and terminate the program
  def parse([0 | rest]), do: [{:halt} | parse(rest)]
  # set: 1 a b - set register <a> to the value of <b>
  def parse([1 | [a | [b | rest]]]), do: [{:set, a, b} | parse(rest)]
  # push: 2 a - push <a> onto the stack
  def parse([2 | [a | rest]]), do: [{:push, a} | parse(rest)]
  # pop: 3 a - remove the top element from the stack and write it into <a>; empty stack = error
  def parse([3 | [a | rest]]), do: [{:pop, a} | parse(rest)]
  # eq: 4 a b c - set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
  def parse([4 | [a | [b | [c | rest]]]]), do: [{:eq, a, b, c} | parse(rest)]
  # gt: 5 a b c - set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
  def parse([5 | [a | [b | [c | rest]]]]), do: [{:gt, a, b, c} | parse(rest)]
  # jmp: 6 a - jump to <a>
  def parse([6 | [a | rest]]), do: [{:jmp, a} | parse(rest)]
  # jt: 7 a b - if <a> is nonzero, jump to <b>
  def parse([7 | [a | [b | rest]]]), do: [{:jt, a, b} | parse(rest)]
  # jf: 8 a b - if <a> is zero, jump to <b>
  def parse([8 | [a | [b | rest]]]), do: [{:jf, a, b} | parse(rest)]
  # add: 9 a b c - assign into <a> the sum of <b> and <c> (modulo 32768)
  def parse([9 | [a | [b | [c | rest]]]]), do: [{:add, a, b, c} | parse(rest)]
  # mult: 10 a b c - store into <a> the product of <b> and <c> (modulo 32768)
  def parse([10 | [a | [b | [c | rest]]]]), do: [{:mult, a, b, c} | parse(rest)]
  # mod: 11 a b c - store into <a> the remainder of <b> divided by <c>
  def parse([11 | [a | [b | [c | rest]]]]), do: [{:mod, a, b, c} | parse(rest)]
  # and: 12 a b c - stores into <a> the bitwise and of <b> and <c>
  def parse([12 | [a | [b | [c | rest]]]]), do: [{:and, a, b, c} | parse(rest)]
  # or: 13 a b c - stores into <a> the bitwise or of <b> and <c>
  def parse([13 | [a | [b | [c | rest]]]]), do: [{:or, a, b, c} | parse(rest)]
  # not: 14 a b - stores 15-bit bitwise inverse of <b> in <a>
  def parse([14 | [a | [b | rest]]]), do: [{:not, a, b} | parse(rest)]
  # rmem: 15 a b - read memory at address <b> and write it to <a>
  def parse([15 | [a | [b | rest]]]), do: [{:rmem, a, b} | parse(rest)]
  # wmem: 16 a b - write the value from <b> into memory at address <a>
  def parse([16 | [a | [b | rest]]]), do: [{:wmem, a, b} | parse(rest)]
  # call: 17 a - write the address of the next instruction to the stack and jump to <a>
  def parse([17 | [a | rest]]), do: [{:call, a} | parse(rest)]
  # ret: 18 - remove the top element from the stack and jump to it; empty stack = halt
  def parse([18 | rest]), do: [{:ret} | parse(rest)]
  # out: 19 a - write the character represented by ascii code <a> to the terminal
  def parse([19 | [a | rest]]), do: [{:out, a} | parse(rest)]
  # in: 20 a - read a character from the terminal and write its ascii code to <a>;
  #     it can be assumed that once input starts, it will continue until a newline is
  #     encountered; this means that you can safely read whole lines from the keyboard
  #     and trust that they will be fully read
  def parse([20 | [a | rest]]), do: [{:in, a} | parse(rest)]
  # noop: 21 - no operation
  def parse([21 | rest]), do: [{:noop} | parse(rest)]

  def parse([first | rest]), do: [first | parse(rest)]
end
