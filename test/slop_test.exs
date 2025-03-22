defmodule SlopTest do
  use ExUnit.Case
  doctest Slop

  test "Slop exports __using__ macro" do
    assert macro_exported?(Slop, :__using__, 1)
  end

  test "Core modules exist" do
    assert Code.ensure_loaded?(Slop.Router)
    assert Code.ensure_loaded?(Slop.Controller)
    assert Code.ensure_loaded?(Slop.Streaming)
    assert Code.ensure_loaded?(Slop.Client)
  end
end
