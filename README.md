# SLOP for Phoenix

A Phoenix router extension that implements the [SLOP (Simple Language Open Protocol)](https://github.com/agnt-gg/slop) for AI service interactions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `slop` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:slop, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/slop>.

## Usage

### In Your Phoenix Router

Add SLOP endpoints to your Phoenix router:

```elixir
defmodule MyAppWeb.Router do
  use Phoenix.Router
  
  pipeline :api do
    plug :accepts, ["json"]
  end
  
  scope "/api/slop", MyAppWeb do
    pipe_through :api
    use Slop, controllers: [
      chat: MyAppWeb.SlopChatController,
      tools: MyAppWeb.SlopToolsController,
      info: MyAppWeb.SlopInfoController
    ]
  end
end
```

### Creating Controllers

Create controllers that implement the SLOP endpoints:

```elixir
defmodule MyAppWeb.SlopChatController do
  use Slop.Controller, :chat
  
  # Override the default implementation
  def handle_chat(_conn, params) do
    messages = params["messages"] || []
    
    # Your AI integration code here
    response = "Hello from SLOP!"
    
    %{
      messages: messages,
      response: response
    }
  end
end

defmodule MyAppWeb.SlopInfoController do
  use Slop.Controller, :info
  
  def get_info(_conn) do
    %{
      name: "My SLOP Server",
      version: "1.0.0",
      endpoints: ["chat", "tools", "info"],
      description: "A Phoenix implementation of the SLOP protocol",
      models: ["gpt-3.5", "gpt-4", "claude-3"]
    }
  end
end
```

### Tools Controller Example

Create a tools controller to expose AI tools:

```elixir
defmodule MyAppWeb.SlopToolsController do
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
  
  def execute_tool(_conn, params) do
    # Identify which tool to run based on parameters
    case params do
      %{"tool_id" => "weather", "params" => %{"location" => location}} ->
        # In a real implementation, you would call a weather API
        %{
          id: "weather",
          result: "The weather in #{location} is sunny and 72°F"
        }
        
      %{"tool_id" => "calculator", "params" => %{"expression" => expression}} ->
        # In a real implementation, you would safely evaluate the expression
        %{
          id: "calculator",
          result: "The result is 42" # Just a placeholder
        }
        
      _ ->
        %{error: "Invalid tool or parameters"}
    end
  end
  
  def execute_specific_tool(_conn, tool_id, params) do
    # Handle a specific tool by ID
    case tool_id do
      "weather" ->
        location = params["params"]["location"]
        %{
          id: "weather",
          result: "The weather in #{location} is sunny and 72°F"
        }
        
      "calculator" ->
        expression = params["params"]["expression"]
        %{
          id: "calculator",
          result: "The result is 42" # Just a placeholder
        }
        
      _ ->
        %{error: "Unknown tool: #{tool_id}"}
    end
  end
end
```

## Endpoint Modules

All SLOP endpoints are optional. You only need to implement the ones your application requires.

| Endpoint   | Controller Type | Description                           |
|------------|----------------|---------------------------------------|
| `/chat`    | `:chat`        | Send messages to and receive responses from AI models |
| `/tools`   | `:tools`       | List available tools and execute them |
| `/memory`  | `:memory`      | Store and retrieve conversation history |
| `/resources` | `:resources` | Access knowledge, files, and other resources |
| `/pay`     | `:pay`         | Handle payment operations |
| `/info`    | `:info`        | Expose server metadata and capabilities |

## SLOP Protocol

For more details on the SLOP protocol, visit [https://github.com/agnt-gg/slop](https://github.com/agnt-gg/slop).

## License

MIT License

