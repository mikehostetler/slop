defmodule Slop.Examples.PhoenixIntegration do
  @moduledoc """
  An example of how to integrate SLOP into a Phoenix application.

  This is a complete example showing how to set up the router, controllers, and
  integrations with an AI service.
  """

  defmodule SlopChatController do
    @moduledoc """
    Example chat controller implementation that integrates with an LLM API.
    """

    use Slop.Controller, :chat

    def handle_chat(conn, params) do
      messages = params["messages"] || []

      if params["stream"] == true do
        # Handle streaming response
        import Slop.Streaming

        conn = start_streaming(conn)

        # In a real implementation, you would stream from an LLM API
        # This is just a mock implementation
        response = "Hello! I'm an AI assistant. I'm here to help you with your questions."

        stream_response(conn, response)
      else
        # Regular non-streaming response
        %{
          response: "Hello! I'm an AI assistant. I'm here to help you with your questions.",
          messages: messages ++ [%{
            role: "assistant",
            content: "Hello! I'm an AI assistant. I'm here to help you with your questions."
          }]
        }
      end
    end
  end

  defmodule SlopToolsController do
    @moduledoc """
    Example tools controller implementation with a few basic tools.
    """

    use Slop.Controller, :tools

    def list_tools(_conn) do
      [
        %{
          id: "weather",
          name: "Weather Lookup",
          description: "Look up the current weather for a location",
          parameters: %{
            type: "object",
            required: ["location"],
            properties: %{
              location: %{
                type: "string",
                description: "The city and state or country"
              }
            }
          }
        },
        %{
          id: "calculator",
          name: "Calculator",
          description: "Perform mathematical calculations",
          parameters: %{
            type: "object",
            required: ["expression"],
            properties: %{
              expression: %{
                type: "string",
                description: "The mathematical expression to evaluate"
              }
            }
          }
        }
      ]
    end

    def execute_tool(_conn, %{"tool_id" => "weather", "params" => %{"location" => location}}) do
      # In a real implementation, you would call a weather API
      %{
        id: "weather",
        result: "The weather in #{location} is sunny and 72°F"
      }
    end

    def execute_tool(_conn, %{"tool_id" => "calculator", "params" => %{"expression" => expression}}) do
      # In a real implementation, you would safely evaluate the expression
      try do
        # CAUTION: This is just for example purposes and not secure for production!
        # You would want to use a proper math parser in a real application
        {result, _} = Code.eval_string(expression)

        %{
          id: "calculator",
          result: "#{expression} = #{result}"
        }
      rescue
        _ ->
          %{
            id: "calculator",
            error: "Could not evaluate expression: #{expression}"
          }
      end
    end

    def execute_tool(_conn, _params) do
      %{error: "Invalid tool or parameters"}
    end

    # Handle specific tool invocation
    def execute_specific_tool(_conn, "weather", %{"params" => %{"location" => location}}) do
      %{
        id: "weather",
        result: "The weather in #{location} is sunny and 72°F"
      }
    end

    def execute_specific_tool(_conn, "calculator", %{"params" => %{"expression" => expression}}) do
      try do
        # CAUTION: This is just for example purposes and not secure for production!
        {result, _} = Code.eval_string(expression)

        %{
          id: "calculator",
          result: "#{expression} = #{result}"
        }
      rescue
        _ ->
          %{
            id: "calculator",
            error: "Could not evaluate expression: #{expression}"
          }
      end
    end

    def execute_specific_tool(_conn, tool_id, _params) do
      %{error: "Unknown tool: #{tool_id}"}
    end
  end

  defmodule SlopInfoController do
    @moduledoc """
    Example info controller implementation.
    """

    use Slop.Controller, :info

    def get_info(_conn) do
      %{
        name: "Example SLOP Server",
        version: "1.0.0",
        endpoints: ["chat", "tools", "info"],
        description: "An example SLOP server implementation",
        models: ["gpt-4", "claude-3"]
      }
    end
  end

  defmodule Router do
    @moduledoc """
    Example router configuration.
    """

    # This is a mock module definition for illustration purposes only
    def router_config do
      """
      defmodule MyAppWeb.Router do
        use Phoenix.Router
        import Plug.Conn
        import Phoenix.Controller

        pipeline :api do
          plug :accepts, ["json"]
        end

        scope "/api", MyAppWeb do
          pipe_through :api

          # SLOP endpoints
          scope "/slop" do
            use Slop, controllers: [
              chat: MyAppWeb.SlopChatController,
              tools: MyAppWeb.SlopToolsController,
              info: MyAppWeb.SlopInfoController
            ]
          end

          # Your other API routes...
        end
      end
      """
    end
  end

  @doc """
  Example of how to call the SLOP endpoints using the Slop.Client module.

  Usage:

  ```elixir
  Slop.Examples.PhoenixIntegration.client_usage()
  ```
  """
  def client_usage do
    """
    # Create a client for your SLOP server
    client = Slop.Client.new("http://localhost:4000/api/slop")

    # Get server info
    {:ok, info} = Slop.Client.info(client)
    IO.inspect(info, label: "Server Info")

    # Send a chat message
    {:ok, response} = Slop.Client.chat(client, [
      %{role: "user", content: "Hello, how are you?"}
    ])
    IO.inspect(response, label: "Chat Response")

    # List available tools
    {:ok, %{"tools" => tools}} = Slop.Client.list_tools(client)
    IO.inspect(tools, label: "Available Tools")

    # Execute a tool
    {:ok, result} = Slop.Client.execute_tool(client, "calculator", %{
      expression: "2 + 2"
    })
    IO.inspect(result, label: "Calculator Result")
    """
  end

  @doc """
  Example of curl commands to use with the SLOP API.
  """
  def curl_examples do
    """
    # Get server info
    curl -X GET http://localhost:4000/api/slop/info

    # Send a chat message
    curl -X POST http://localhost:4000/api/slop/chat \\
      -H "Content-Type: application/json" \\
      -d '{"messages":[{"role":"user","content":"Hello, how are you?"}]}'

    # Send a chat message with streaming enabled
    curl -X POST http://localhost:4000/api/slop/chat \\
      -H "Content-Type: application/json" \\
      -d '{"messages":[{"role":"user","content":"Hello, how are you?"}],"stream":true}'

    # List available tools
    curl -X GET http://localhost:4000/api/slop/tools

    # Execute a tool
    curl -X POST http://localhost:4000/api/slop/tools \\
      -H "Content-Type: application/json" \\
      -d '{"tool_id":"calculator","params":{"expression":"2 + 2"}}'

    # Execute a specific tool
    curl -X POST http://localhost:4000/api/slop/tools/weather \\
      -H "Content-Type: application/json" \\
      -d '{"params":{"location":"New York"}}'
    """
  end
end
