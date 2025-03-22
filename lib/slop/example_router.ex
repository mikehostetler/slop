defmodule Slop.ExampleRouter do
  @moduledoc """
  An example of how to use the Slop module in a Phoenix router.

  This is not meant to be used directly, but to serve as a reference for
  how to implement SLOP in your own Phoenix application.
  """

  # This is a mock module definition for illustration purposes only
  defmodule ExampleChatController do
    use Slop.Controller, :chat

    def handle_chat(_conn, params) do
      messages = params["messages"] || []
      user_message = List.last(messages)["content"] || ""

      # In a real implementation, this would call an AI service API
      %{
        response: "You said: #{user_message}",
        messages:
          messages ++
            [
              %{
                role: "assistant",
                content: "You said: #{user_message}"
              }
            ]
      }
    end
  end

  defmodule ExampleInfoController do
    use Slop.Controller, :info

    def get_info(_conn) do
      %{
        name: "Example SLOP Server",
        version: "1.0.0",
        endpoints: ["chat", "info"],
        description: "An example SLOP server for demonstration purposes",
        models: ["example-model"]
      }
    end
  end

  # This represents how you would define your Phoenix router
  def example_router_config do
    """
    defmodule MyAppWeb.Router do
      use Phoenix.Router

      pipeline :api do
        plug :accepts, ["json"]
      end

      scope "/api/slop", MyAppWeb do
        pipe_through :api
        use Slop, controllers: [
          chat: MyAppWeb.SlopChatController,
          info: MyAppWeb.SlopInfoController
        ]
      end
    end
    """
  end
end
