defmodule VirtualMachine.MixProject do
  use Mix.Project

  def project do
    [
      app: :virtual_machine,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {VirtualMachine.Application, []}
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.6.0", only: :dev, runtime: false}
    ]
  end
end
