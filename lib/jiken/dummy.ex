defmodule Jiken.Dummy do
  @moduledoc """
  Used as a dummy module to test Jiken functionality.
  """

  def greet do
    IO.puts("Hello, world!")
  end

  def greet(name) do
    IO.puts("Hello, #{name}!")
  end
end
