defmodule Jiken.Loaders.Unmock do
  @moduledoc """
  This module handles the reverting of a mocked module.
  
  Currently, it reloads the whole original module.

  We will make it reload only specific functions,
  so that we can dynamically mock different parts of modules.
  """

  @spec reset(module) :: :ok | {:error, :not_found}
  def reset(module) do
    case :ets.lookup(Jiken.original_modules_table(), module) do
      [{_, {_original_name, binary, path}}] ->
        Code.compiler_options(ignore_module_conflict: true)
        :code.load_binary(module, path, binary)
        :ets.delete(Jiken.original_modules_table(), module)

        # if necesary to clean up any mocked functions
        # extract in a separate interface
        # :ets.match_delete(@mocked_modules, {{module, :_}, :_}) 
        :ok
      [] ->
        {:error, :not_found}
    end
  end
end
