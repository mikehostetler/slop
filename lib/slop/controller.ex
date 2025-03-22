defmodule Slop.Controller do
  @moduledoc """
  Provides default controller implementations for SLOP (Simple Language Open Protocol) endpoints.

  This module can be used to quickly implement SLOP-compliant controllers in a Phoenix application
  by providing default implementations for all the standard SLOP endpoints.

  ## Usage

  ```elixir
  defmodule MyAppWeb.SlopChatController do
    use Slop.Controller, :chat

    # Override the default implementation
    def handle_chat(conn, params) do
      # Your custom chat implementation
      # ...

      json(conn, %{response: "Hello from SLOP!"})
    end
  end
  ```

  You can also implement only specific callbacks:

  ```elixir
  defmodule MyAppWeb.SlopInfoController do
    use Slop.Controller, :info

    # The default implementation will be used for other callbacks
    def get_info(_conn) do
      %{
        name: "My Custom SLOP Server",
        version: "1.0.0",
        endpoints: ["chat", "info"],
        models: ["gpt-4", "claude-3"]
      }
    end
  end
  """

  @doc """
  Defines the controller implementation for a specific SLOP endpoint type.

  ## Options

  * `:chat` - Implements a controller for the /chat endpoint
  * `:tools` - Implements a controller for the /tools endpoints
  * `:memory` - Implements a controller for the /memory endpoints
  * `:resources` - Implements a controller for the /resources endpoints
  * `:pay` - Implements a controller for the /pay endpoint
  * `:info` - Implements a controller for the /info endpoint
  """
  defmacro __using__(endpoint_type) do
    quote do
      use Phoenix.Controller, namespace: Slop
      import Plug.Conn

      case unquote(endpoint_type) do
        :chat ->
          @impl true
          def create(conn, params) do
            response = handle_chat(conn, params)

            if is_map(response) do
              json(conn, response)
            else
              response
            end
          end

          @doc """
          Process a chat request and return a response.

          This callback should be implemented to handle chat requests. It should return
          either a map that will be encoded to JSON, or a connection to support streaming.
          """
          def handle_chat(_conn, _params) do
            %{error: "Not implemented"}
          end

          defoverridable handle_chat: 2

        :tools ->
          @impl true
          def index(conn, _params) do
            tools = list_tools(conn)
            json(conn, %{tools: tools})
          end

          @impl true
          def invoke(conn, params) do
            response = execute_tool(conn, params)

            if is_map(response) do
              json(conn, response)
            else
              response
            end
          end

          @impl true
          def invoke_specific(conn, %{"tool_id" => tool_id} = params) do
            response = execute_specific_tool(conn, tool_id, params)

            if is_map(response) do
              json(conn, response)
            else
              response
            end
          end

          @doc """
          List available tools.

          This callback should return a list of tools that are available for use.
          """
          def list_tools(_conn) do
            []
          end

          @doc """
          Execute a tool based on the provided parameters.

          This callback should implement the logic to execute the requested tool.
          """
          def execute_tool(_conn, _params) do
            %{error: "Not implemented"}
          end

          @doc """
          Execute a specific tool by ID.

          This callback should implement the logic to execute a specific tool by ID.
          """
          def execute_specific_tool(_conn, _tool_id, _params) do
            %{error: "Not implemented"}
          end

          defoverridable list_tools: 1, execute_tool: 2, execute_specific_tool: 3

        :memory ->
          @impl true
          def index(conn, params) do
            memories = list_memories(conn, params)
            json(conn, %{memories: memories})
          end

          @impl true
          def show(conn, %{"id" => id} = params) do
            case get_memory(conn, id, params) do
              {:ok, memory} -> json(conn, %{memory: memory})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @impl true
          def create(conn, params) do
            case create_memory(conn, params) do
              {:ok, memory} -> json(conn, %{memory: memory})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @impl true
          def update(conn, %{"id" => id} = params) do
            case update_memory(conn, id, params) do
              {:ok, memory} -> json(conn, %{memory: memory})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @impl true
          def delete(conn, %{"id" => id} = params) do
            case delete_memory(conn, id, params) do
              :ok -> json(conn, %{status: "deleted"})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @doc """
          List memories based on the provided parameters.

          This callback should return a list of memories.
          """
          def list_memories(_conn, _params) do
            []
          end

          @doc """
          Get a specific memory by ID.

          This callback should return {:ok, memory} or {:error, reason}.
          """
          def get_memory(_conn, _id, _params) do
            {:error, "Not implemented"}
          end

          @doc """
          Create a new memory.

          This callback should return {:ok, memory} or {:error, reason}.
          """
          def create_memory(_conn, _params) do
            {:error, "Not implemented"}
          end

          @doc """
          Update an existing memory.

          This callback should return {:ok, memory} or {:error, reason}.
          """
          def update_memory(_conn, _id, _params) do
            {:error, "Not implemented"}
          end

          @doc """
          Delete a memory by ID.

          This callback should return :ok or {:error, reason}.
          """
          def delete_memory(_conn, _id, _params) do
            {:error, "Not implemented"}
          end

          defoverridable list_memories: 2,
                         get_memory: 3,
                         create_memory: 2,
                         update_memory: 3,
                         delete_memory: 3

        :resources ->
          @impl true
          def index(conn, params) do
            resources = list_resources(conn, params)
            json(conn, %{resources: resources})
          end

          @impl true
          def show(conn, %{"id" => id} = params) do
            case get_resource(conn, id, params) do
              {:ok, resource} -> json(conn, %{resource: resource})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @impl true
          def create(conn, params) do
            case create_resource(conn, params) do
              {:ok, resource} -> json(conn, %{resource: resource})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @impl true
          def search(conn, params) do
            results = search_resources(conn, params)
            json(conn, %{results: results})
          end

          @doc """
          List resources based on the provided parameters.

          This callback should return a list of resources.
          """
          def list_resources(_conn, _params) do
            []
          end

          @doc """
          Get a specific resource by ID.

          This callback should return {:ok, resource} or {:error, reason}.
          """
          def get_resource(_conn, _id, _params) do
            {:error, "Not implemented"}
          end

          @doc """
          Create a new resource.

          This callback should return {:ok, resource} or {:error, reason}.
          """
          def create_resource(_conn, _params) do
            {:error, "Not implemented"}
          end

          @doc """
          Search for resources based on a query.

          This callback should return a list of search results.
          """
          def search_resources(_conn, _params) do
            []
          end

          defoverridable list_resources: 2,
                         get_resource: 3,
                         create_resource: 2,
                         search_resources: 2

        :pay ->
          @impl true
          def create(conn, params) do
            case process_payment(conn, params) do
              {:ok, payment} -> json(conn, %{payment: payment})
              {:error, reason} -> json(conn, %{error: reason})
            end
          end

          @doc """
          Process a payment request.

          This callback should return {:ok, payment} or {:error, reason}.
          """
          def process_payment(_conn, _params) do
            {:error, "Not implemented"}
          end

          defoverridable process_payment: 2

        :info ->
          @impl true
          def show(conn, _params) do
            info = get_info(conn)
            json(conn, info)
          end

          @doc """
          Get information about the SLOP server.

          This callback should return a map containing information about the server.
          """
          def get_info(_conn) do
            %{
              name: "SLOP Server",
              version: "1.0.0",
              endpoints: [],
              description: "SLOP (Simple Language Open Protocol) server"
            }
          end

          defoverridable get_info: 1
      end
    end
  end
end
