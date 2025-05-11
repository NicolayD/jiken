defmodule JikenTest do
  use ExUnit.Case
  doctest Jiken

  test "replaces a function's code with an exception" do
    module = Jiken
    function = :dummy
    error_function = fn -> raise "Error" end
    
    assert Jiken.instrument(module, function, error_function)
  end
end
