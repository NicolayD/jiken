defmodule Jiken.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = get_configured_simulators()

    Jiken.init()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jiken.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_configured_simulators() do
    case Application.fetch_env(:jiken, :simulators) do
      :error -> []
      config -> config_simulators(config)
    end
  end

  defp config_simulators(config) do
    for {simulator, spec} <- config do
      strategy = Keyword.fetch!(spec, :strategy)

      state = %{
        module: simulator.module,
        function: simulator.function,
        arity: simulator.arity
      }

      %{
        id: "#{Enum.join("-", Map.values(state))}",
        start: {strategy, :start_link, [state]}
      }
    end
  end
end
