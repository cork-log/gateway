defmodule Gateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :gateway,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mongodb_ecto, :ecto, :grpc],
      mod: {Gateway.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:mongodb_ecto, "~> 0.1"},
      {:protobuf, "~> 0.5.3"},
      {:elixir_uuid, "~> 1.2"},
      {:grpc, git: "https://github.com/tony612/grpc-elixir.git"},
      {:cartograf, git: "https://github.com/Herlitzd/cartograf.git"},
      {:joken, "~> 1.1"},
      {:poison, "~> 3.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
    ]
  end
end
