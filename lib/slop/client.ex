defmodule Slop.Client do
  @moduledoc """
  A client for consuming SLOP (Simple Language Open Protocol) APIs.

  This module provides functions for interacting with SLOP servers, making it
  easy to send requests to the standard SLOP endpoints.

  ## Usage

  ```elixir
  # Initialize a client
  client = Slop.Client.new("https://my-slop-server.com")

  # Get server information
  {:ok, info} = Slop.Client.info(client)

  # Send a chat message
  {:ok, response} = Slop.Client.chat(client, [
    %{role: "user", content: "Hello, how are you?"}
  ])

  # List available tools
  {:ok, tools} = Slop.Client.list_tools(client)

  # Execute a tool
  {:ok, result} = Slop.Client.execute_tool(client, "calculator", %{
    expression: "2 + 2"
  })
  ```
  """

  @type t :: %__MODULE__{
    base_url: String.t(),
    headers: [{String.t(), String.t()}],
    http_client: module()
  }

  defstruct [
    :base_url,
    headers: [],
    http_client: HTTPoison
  ]

  @doc """
  Creates a new SLOP client.

  ## Options

  * `:headers` - Additional headers to include in requests
  * `:http_client` - The HTTP client module to use (default: `HTTPoison`)

  ## Examples

  ```elixir
  # Basic client
  client = Slop.Client.new("https://my-slop-server.com")

  # Client with authentication
  client = Slop.Client.new("https://my-slop-server.com",
    headers: [{"Authorization", "Bearer my-token"}]
  )
  ```
  """
  @spec new(String.t(), keyword()) :: t()
  def new(base_url, opts \\ []) do
    headers = Keyword.get(opts, :headers, [])
    http_client = Keyword.get(opts, :http_client, HTTPoison)

    %__MODULE__{
      base_url: String.trim_trailing(base_url, "/"),
      headers: headers,
      http_client: http_client
    }
  end

  @doc """
  Gets information about the SLOP server.

  ## Examples

  ```elixir
  {:ok, info} = Slop.Client.info(client)

  # info = %{
  #   "name" => "Example SLOP Server",
  #   "version" => "1.0.0",
  #   "endpoints" => ["chat", "info"],
  #   ...
  # }
  ```
  """
  @spec info(t()) :: {:ok, map()} | {:error, term()}
  def info(client) do
    get(client, "/info")
  end

  @doc """
  Sends a chat message to the SLOP server.

  ## Examples

  ```elixir
  {:ok, response} = Slop.Client.chat(client, [
    %{role: "user", content: "Hello, how are you?"}
  ])

  # response = %{
  #   "response" => "I'm doing well, thank you for asking!",
  #   "messages" => [
  #     %{"role" => "user", "content" => "Hello, how are you?"},
  #     %{"role" => "assistant", "content" => "I'm doing well, thank you for asking!"}
  #   ]
  # }
  ```
  """
  @spec chat(t(), list(map())) :: {:ok, map()} | {:error, term()}
  def chat(client, messages) do
    post(client, "/chat", %{messages: messages})
  end

  @doc """
  Lists the tools available on the SLOP server.

  ## Examples

  ```elixir
  {:ok, %{"tools" => tools}} = Slop.Client.list_tools(client)

  # tools = [
  #   %{
  #     "id" => "calculator",
  #     "name" => "Calculator",
  #     "description" => "Perform mathematical calculations",
  #     ...
  #   },
  #   ...
  # ]
  ```
  """
  @spec list_tools(t()) :: {:ok, map()} | {:error, term()}
  def list_tools(client) do
    get(client, "/tools")
  end

  @doc """
  Executes a tool on the SLOP server.

  ## Examples

  ```elixir
  {:ok, result} = Slop.Client.execute_tool(client, "calculator", %{
    expression: "2 + 2"
  })

  # result = %{
  #   "id" => "calculator",
  #   "result" => "The result is 4"
  # }
  ```
  """
  @spec execute_tool(t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def execute_tool(client, tool_id, params) do
    post(client, "/tools/#{tool_id}", %{params: params})
  end

  @doc """
  Gets resources from the SLOP server.

  ## Examples

  ```elixir
  {:ok, %{"resources" => resources}} = Slop.Client.list_resources(client)

  # resources = [
  #   %{
  #     "id" => "article-1",
  #     "title" => "Article 1",
  #     ...
  #   },
  #   ...
  # ]
  ```
  """
  @spec list_resources(t()) :: {:ok, map()} | {:error, term()}
  def list_resources(client) do
    get(client, "/resources")
  end

  @doc """
  Gets a specific resource from the SLOP server.

  ## Examples

  ```elixir
  {:ok, %{"resource" => resource}} = Slop.Client.get_resource(client, "article-1")

  # resource = %{
  #   "id" => "article-1",
  #   "title" => "Article 1",
  #   "content" => "...",
  #   ...
  # }
  ```
  """
  @spec get_resource(t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get_resource(client, resource_id) do
    get(client, "/resources/#{resource_id}")
  end

  @doc """
  Searches for resources on the SLOP server.

  ## Examples

  ```elixir
  {:ok, %{"results" => results}} = Slop.Client.search_resources(client, "example")

  # results = [
  #   %{
  #     "id" => "article-1",
  #     "title" => "Example Article",
  #     "score" => 0.9,
  #     ...
  #   },
  #   ...
  # ]
  ```
  """
  @spec search_resources(t(), String.t()) :: {:ok, map()} | {:error, term()}
  def search_resources(client, query) do
    get(client, "/resources/search?q=#{URI.encode(query)}")
  end

  # Helper functions for making HTTP requests

  defp get(client, path) do
    url = client.base_url <> path

    case client.http_client.get(url, client.headers) do
      {:ok, %{status_code: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status_code: status, body: body}} ->
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp post(client, path, data) do
    url = client.base_url <> path
    body = Jason.encode!(data)
    headers = [{"Content-Type", "application/json"} | client.headers]

    case client.http_client.post(url, body, headers) do
      {:ok, %{status_code: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status_code: status, body: body}} ->
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
