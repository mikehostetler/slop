defmodule SlopTest do
  use ExUnit.Case
  doctest Slop

  describe "Slop module" do
    test "exports __using__ macro" do
      assert macro_exported?(Slop, :__using__, 1)
    end
  end

  describe "Slop.Router" do
    test "exports __using__ macro" do
      assert macro_exported?(Slop.Router, :__using__, 1)
    end
  end

  describe "Slop.Controller" do
    test "exports __using__ macro" do
      assert macro_exported?(Slop.Controller, :__using__, 1)
    end
  end

  describe "Slop.Streaming" do
    test "provides streaming helper functions" do
      # Test that the Slop.Streaming module defines the expected functions
      assert function_exported?(Slop.Streaming, :start_streaming, 1)
      assert function_exported?(Slop.Streaming, :stream_chunk, 2)
      assert function_exported?(Slop.Streaming, :stream_response, 3)
    end
  end

  describe "Slop.Client" do
    test "provides functions for interacting with SLOP servers" do
      # Test that the Slop.Client module defines the expected functions
      assert function_exported?(Slop.Client, :new, 2)
      assert function_exported?(Slop.Client, :info, 1)
      assert function_exported?(Slop.Client, :chat, 2)
      assert function_exported?(Slop.Client, :list_tools, 1)
      assert function_exported?(Slop.Client, :execute_tool, 3)
    end
  end
end
