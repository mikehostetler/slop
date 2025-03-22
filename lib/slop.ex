defmodule Slop do
  @moduledoc """
  SLOP - Simple Language Open Protocol for Elixir / Phoenix

  SLOP defines a simple, standardized set of HTTP endpoints for AI service interactions.
  It provides a modular, easy-to-implement REST API pattern for building AI applications.

  ## Key Endpoints

  * `/chat` - For sending messages to and receiving responses from AI models
  * `/tools` - For listing available tools and executing them
  * `/memory` - For storing and retrieving conversation history or other data
  * `/resources` - For accessing knowledge, files, and other resources
  * `/pay` - For handling payment-related operations
  * `/info` - For exposing server metadata and capabilities

  ## Usage in Phoenix Router

  ```elixir
  defmodule MyAppWeb.Router do
    use Phoenix.Router

    # Your existing pipeline definitions
    pipeline :api do
      plug :accepts, ["json"]
    end

    # Use the SLOP router in a scope
    scope "/api/slop", MyAppWeb do
      pipe_through :api
      use Slop.Router, controllers: [
        chat: MyAppWeb.SlopChatController,
        tools: MyAppWeb.SlopToolsController,
        memory: MyAppWeb.SlopMemoryController,
        resources: MyAppWeb.SlopResourcesController,
        pay: MyAppWeb.SlopPayController,
        info: MyAppWeb.SlopInfoController
      ]
    end
  end
  ```

  ## Implementing Controllers

  ```elixir
  defmodule MyAppWeb.SlopChatController do
    use Slop.Controller, :chat

    # Override the default implementation
    def handle_chat(_conn, params) do
      messages = params["messages"] || []

      # Your AI integration code here
      # ...

      %{
        messages: messages,
        response: "Hello from SLOP!"
      }
    end
  end
  ```

  For more information on the SLOP protocol, visit https://github.com/agnt-gg/slop
  """

  @doc """
  Use in Phoenix Router to add SLOP endpoints to your application.

  This is a convenience function that delegates to Slop.Router.

  ## Example

  ```elixir
  defmodule MyAppWeb.Router do
    use Phoenix.Router

    scope "/api/slop", MyAppWeb do
      pipe_through :api
      use Slop, controllers: [
        chat: MyAppWeb.SlopChatController,
        info: MyAppWeb.SlopInfoController
      ]
    end
  end
  ```

  See `Slop.Router` for more details on the available options.
  """
  defmacro __using__(opts) do
    quote do
      use Slop.Router, unquote(opts)
    end
  end
end
