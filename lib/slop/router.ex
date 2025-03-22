defmodule Slop.Router do
  @moduledoc """
  A Phoenix router extension for implementing SLOP (Simple Language Open Protocol) endpoints.

  This module provides a macro that can be used in a Phoenix router to quickly set up
  the standard SLOP endpoints for AI interactions.

  ## Usage

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

  ## Configuration

  The `use Slop.Router` macro accepts a keyword list with the following options:

  * `:controllers` - A map of SLOP endpoint types to controller modules that will handle
    the corresponding requests. You only need to specify the controllers for the endpoints
    you want to implement.
  """

  defmacro __using__(opts) do
    quote do
      # Extract controller modules from the options
      controllers = Keyword.get(unquote(opts), :controllers, %{})

      # Define routes for each of the core SLOP endpoints if a controller is provided

      # 1. Chat endpoint
      if chat_controller = Keyword.get(controllers, :chat) do
        post("/chat", chat_controller, :create)
      end

      # 2. Tools endpoints
      if tools_controller = Keyword.get(controllers, :tools) do
        get("/tools", tools_controller, :index)
        post("/tools", tools_controller, :invoke)
        post("/tools/:tool_id", tools_controller, :invoke_specific)
      end

      # 3. Memory endpoints
      if memory_controller = Keyword.get(controllers, :memory) do
        get("/memory", memory_controller, :index)
        get("/memory/:id", memory_controller, :show)
        post("/memory", memory_controller, :create)
        put("/memory/:id", memory_controller, :update)
        delete("/memory/:id", memory_controller, :delete)
      end

      # 4. Resources endpoints
      if resources_controller = Keyword.get(controllers, :resources) do
        get("/resources", resources_controller, :index)
        get("/resources/:id", resources_controller, :show)
        post("/resources", resources_controller, :create)
        get("/resources/search", resources_controller, :search)
      end

      # 5. Pay endpoint
      if pay_controller = Keyword.get(controllers, :pay) do
        post("/pay", pay_controller, :create)
      end

      # 6. Info endpoint
      if info_controller = Keyword.get(controllers, :info) do
        get("/info", info_controller, :show)
      end
    end
  end
end
