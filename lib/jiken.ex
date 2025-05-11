defmodule Jiken do
  @moduledoc """
  `Jiken` is a library for dynamically mocking and unmocking functions in Elixir modules.

  Its main goal is to be used for simulation testing in development.

  It provides an API to set up when and how different functions should be mocked, and then reset.

  The goal is to be able to do something like the following: 
    - make a function predictably raise an exception at a certain time 
    - make a function predictably raise an exception after a certain amount of reductions (function calls)
    - make a function raise an exception in a pseudo-random manner
    - load and use production exceptions from AppSignal, Sentry, or Datadog

  The purpose of `Jiken` is to be able to test critical functionality by easily simulating breaking scenarios.

  ## Examples

  Consider the `Jiken.Dummy` module, which can be found here in the library itself.
  It has the `greet/0` function.

    ```
    def greet do
      IO.puts("Hello, world!")
    end
    ```

  This is how it can be dynamically mocked with `Jiken`.

      iex> Jiken.Dummy()
      "Hello, world!"
      :ok 
  
      iex> Jiken.set(Jiken.Dummy, :greet, fn -> IO.puts("Hello, simulation!") end)

      iex> Jiken.Dummy()
      Hello, simulation!
      :ok
  
      iex> Jiken.reset(Jiken.Dummy)
      :ok
  
      iex> Jiken.Dummy()
      Hello, world!
      :ok
  """
  
  alias Jiken.Loaders.{Mock, Unmock}
  
  defdelegate set(module, function_name, new_implementation, opts \\ []), to: Mock
  defdelegate reset(module), to: Unmock

  @mocked_modules_table :jiken_mocked_modules
  @original_modules_table :jiken_original_modules

  def init do
    :ets.new(@mocked_modules_table, [:set, :public, :named_table])
    :ets.new(@original_modules_table, [:set, :public, :named_table])
  end
  
  def mocked_modules_table(), do: @mocked_modules_table
  def original_modules_table(), do: @original_modules_table
end
