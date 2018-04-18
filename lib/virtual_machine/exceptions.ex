defmodule VirtualMachine.Exceptions do
  defmodule InvalidRegisterError do
    defexception [:message]
  end

  defmodule StackIsEmptyError do
    defexception [:message]
  end
end
