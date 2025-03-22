defmodule Slop.Streaming do
  @moduledoc """
  Provides helpers for streaming responses in SLOP protocol endpoints.

  The SLOP protocol supports streaming responses through various mechanisms:

  1. Server-Sent Events (SSE)
  2. Chunked transfers
  3. WebSockets

  This module provides helpers for implementing streaming in Phoenix controllers
  that implement SLOP endpoints.

  ## Usage

  ```elixir
  defmodule MyAppWeb.SlopChatController do
    use Slop.Controller, :chat
    import Slop.Streaming

    def handle_chat(conn, params) do
      # Start streaming response
      conn = start_streaming(conn)

      # Process messages and stream chunks
      messages = params["messages"] || []

      # Stream back tokens one by one (simulating AI response)
      response = "Hello, I am an AI assistant. How can I help you today?"

      for word <- String.split(response) do
        :timer.sleep(100) # Simulate thinking time
        stream_chunk(conn, %{
          type: "content",
          content: word <> " "
        })
      end

      # Signal completion
      stream_chunk(conn, %{
        type: "done",
        content: ""
      })

      # Return the connection
      conn
    end
  end
  ```
  """

  import Plug.Conn

  @doc """
  Starts streaming a response using Server-Sent Events (SSE).

  Returns a connection that's ready for streaming chunks.
  """
  def start_streaming(conn) do
    conn
    |> put_resp_content_type("text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> put_resp_header("connection", "keep-alive")
    |> send_chunked(200)
  end

  @doc """
  Sends a chunk of data in the standard SLOP streaming format.

  The chunk should be a map that will be converted to JSON. The map should
  include a `type` field that indicates the type of chunk:

  - "content" - A piece of content being streamed
  - "done" - Signals that the stream is complete
  - "error" - Indicates an error occurred
  - "thinking" - Indicates the AI is processing (optional)
  - "tool_start" - Indicates a tool is being called (optional)
  - "tool_result" - Contains the result of a tool call (optional)

  ## Examples

  ```elixir
  stream_chunk(conn, %{type: "content", content: "Hello, "})
  stream_chunk(conn, %{type: "content", content: "world!"})
  stream_chunk(conn, %{type: "done", content: ""})
  ```
  """
  def stream_chunk(conn, data) do
    json = Jason.encode!(data)
    chunk(conn, "data: #{json}\n\n")
  end

  @doc """
  Starts a chunked transfer response for streaming in simple HTTP chunked mode.

  Returns a connection that's ready for streaming chunks.
  """
  def start_chunked_streaming(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_chunked(200)
  end

  @doc """
  Helper for streaming a complete AI response word by word.

  This function takes care of the streaming logic, including starting the stream,
  sending content chunks, and ending the stream.

  ## Example

  ```elixir
  def handle_chat(conn, params) do
    messages = params["messages"] || []

    # In a real implementation, call an AI API that streams tokens
    response = "Hello, I am an AI assistant. How can I help you today?"

    stream_response(conn, response, fn word, _index ->
      :timer.sleep(100) # Simulate thinking time
      word <> " "
    end)
  end
  """
  def stream_response(conn, response, word_transformer \\ &(&1 <> " ")) do
    conn = start_streaming(conn)

    words = String.split(response)

    for {word, i} <- Enum.with_index(words) do
      transformed = word_transformer.(word, i)

      stream_chunk(conn, %{
        type: "content",
        content: transformed
      })
    end

    stream_chunk(conn, %{
      type: "done",
      content: ""
    })

    conn
  end
end
