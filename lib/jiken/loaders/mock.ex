defmodule Jiken.Loaders.Mock do
  @moduledoc """
  All functionality related to overwriting code is handled in this module.
  
  Jiken first checks if the mocked function exists.
  If it does, it stores the original module with a suffix to its namespace of .Original.
  It is stored in ETS.
  
  Jiken also stores the mocked implementation in a different ETS table.
  Globally mocked functions and per-process mocks are stored separately.

  Then, Jiken goes through all of the function definitions of the module until it finds the mocked function,
  it updates its implementation to mocked version of the function from ETS,
  depending on if it is mocked globally or per process.
  
  If it cannot find a mock at this step, it falls back to the original implementation.
  """

  def set(module, function_name, new_implementation, opts \\ []) do
    impl_arity = :erlang.fun_info(new_implementation)[:arity]
    original_functions = module.__info__(:functions)

    if function_exists?(original_functions, function_name, impl_arity) do
      ensure_original_module_stored(module)
      store_implementation(module, function_name, new_implementation, opts)

      module
      |> generate_function_definitions(original_functions, function_name, impl_arity)
      |> recompile_module(module)

      {:ok, {module, function_name, impl_arity}}
    else
      {:error, :function_not_found}
    end
  end
  
  defp function_exists?(existing_functions, function_name, arity) do
    Enum.any?(existing_functions, fn {name, ar} ->
      name == function_name and ar == arity
    end)
  end

  defp ensure_original_module_stored(module) do
    if :ets.lookup(Jiken.original_modules_table(), module) == [] do
      original_module_name = Module.concat(module, "Original")
      store_original_module(module, original_module_name)
    end
  end

  defp recompile_module(function_definitions, module) do
    Code.eval_quoted(
      quote do
        defmodule unquote(module) do
          unquote_splicing(function_definitions)
        end
      end
    )

    :ok
  end
  
  defp store_original_module(module, original_name) do
    {:ok, binary} = get_beam_binary(module)

    Code.compiler_options(ignore_module_conflict: true)

    # possibly unnecessary
    # also, currently the Original module mocked calls the mocked implementation still
    # instead of the original implementation
    # we can keep this logic if we refactor it to load the original module definition
    # 
    # function_definitions = get_original_function_definitions(module, original_functions)
    
    # Code.eval_quoted(
    #   quote do
    #     defmodule unquote(original_name) do
    #       unquote_splicing(function_definitions)
    #     end
    #   end
    # )

    # store both the original name and the binary
    original_path = module.__info__(:compile)[:source]
    :ets.insert(Jiken.original_modules_table(), {module, {original_name, binary, original_path}})
  end

  defp store_implementation(module, function_name, implementation, opts) do
    impl_key = {module, function_name}
    scope = Keyword.get(opts, :scope, :global)

    case scope do
      :global ->
        :ets.insert(Jiken.mocked_modules_table(), {impl_key, implementation})
      :process ->
        process_key = {impl_key, self()}
        :ets.insert(Jiken.mocked_modules_table(), {process_key, implementation})
    end
  end
  
  defp get_beam_binary(module) do
    case :code.get_object_code(module) do
      {^module, binary, _beam_path} -> {:ok, binary}
      :error -> :error
    end
  end

  defp generate_args(0), do: []

  defp generate_args(arity) do
    # maybe we should use the original Module instead of nil 
    # so that we generate hygienic variables
    # currently the variable is unhygienic
    for i <- Range.new(1, arity), do: Macro.var(:"arg#{i}", nil)
  end

  defp generate_function_definitions(module, existing_functions, target_function, impl_arity) do
    for {name, arity} <- existing_functions do
      if name == target_function and arity == impl_arity do
        generate_mocked_function(module, name, arity)
      else
        generate_original_function(module, name, arity)
      end
    end
  end

  defp generate_mocked_function(module, name, arity) do
    impl_key = {module, name}

    args = generate_args(arity)

    quote do
      def unquote(name)(unquote_splicing(args)) do
        process_key = {unquote(Macro.escape(impl_key)), self()}

        case :ets.lookup(unquote(Jiken.mocked_modules_table()), process_key) do
          [{_, impl}] -> impl.()
          [] ->
            case :ets.lookup(unquote(Jiken.mocked_modules_table()), unquote(Macro.escape(impl_key))) do
              [{_, impl}] -> impl.()
              [] ->
                # maybe we could just call the original module directly instead of Original
                # also I think currently we don't load the Original module in memory
                original_module = Module.concat(unquote(module), "Original")
                apply(original_module, unquote(name), [])
            end
        end
      end
    end
  end

  defp generate_original_function(module, name, arity) do
    args = generate_args(arity)

    quote do
      def unquote(name)(unquote_splicing(args)) do
        original_module_name = Module.concat(unquote(module), "Original")
        apply(original_module_name, unquote(name), [unquote_splicing(args)])
      end
    end
  end
  
  # defp get_original_function_definitions(module, original_functions) do
  #   for {name, arity} <- original_functions do
  #     args = generate_args(arity)

  #     quote do
  #       def unquote(name)(unquote_splicing(args)) do
  #         apply(unquote(module), unquote(name), [unquote_splicing(args)])
  #       end
  #     end
  #   end
  # end
end