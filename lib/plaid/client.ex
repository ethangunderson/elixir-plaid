defmodule Plaid.Client do
  @moduledoc false
  use HTTPoison.Base

  require Logger

  alias Plaid.Castable

  def process_request_headers(headers) do
    [{"Content-Type", "application/json"}] ++ headers
  end

  @doc """
  Make a Plaid API call.

  Takes in everything needed to complete the request and
  return a well formed struct of the response.

  ## Examples

      call(
        "/categories/get",
        %{},
        Plaid.Categories.GetResponse,
        client_id: "123",
        secret: "abc"
      )
      {:ok, %Plaid.Categories.GetResponse{}}

  """
  @spec call(String.t(), map(), module(), Plaid.config()) ::
          {:ok, any()} | {:error, Plaid.Error.t()}
  def call(endpoint, payload \\ %{}, castable_module, config) do
    url = build_url(config, endpoint)

    payload =
      payload
      |> add_auth(config)
      |> Jason.encode!()

    :post
    |> request(url, payload, recv_timeout: 60_000)
    |> handle_response(castable_module)
  end

  @spec build_url(Plaid.config(), String.t()) :: String.t()
  defp build_url(config, endpoint) do
    test_api_host = Keyword.get(config, :test_api_host)

    if is_binary(test_api_host) do
      test_api_host <> endpoint
    else
      env = Keyword.get(config, :env, :sandbox)
      "https://#{env}.plaid.com#{endpoint}"
    end
  end

  @spec add_auth(map(), Plaid.config()) :: map()
  defp add_auth(payload, config) do
    auth =
      config
      |> Map.new()
      |> Map.take([:client_id, :secret])

    Map.merge(payload, auth)
  end

  @spec handle_response(
          {:ok,
           HTTPoison.Response.t()
           | HTTPoison.AsyncResponse.t()
           | HTTPoison.MaybeRedirect.t()}
          | {:error, HTTPoison.Error.t()},
          module() | :raw
        ) :: {:ok, any()} | {:error, Plaid.Error.t()}
  def handle_response({:ok, %{body: body, status_code: status_code}}, :raw)
      when status_code in 200..299 do
    {:ok, body}
  end

  def handle_response({:ok, %{body: json_body, status_code: status_code}}, castable_module)
      when status_code in 200..299 do
    case Jason.decode(json_body) do
      {:ok, generic_map} -> {:ok, Castable.cast(castable_module, generic_map)}
      _ -> {:error, Castable.cast(Plaid.Error, %{})}
    end
  end

  def handle_response({:ok, %{body: json_body}}, _castable_module) do
    case Jason.decode(json_body) do
      {:ok, generic_map} -> {:error, Castable.cast(Plaid.Error, generic_map)}
      _ -> {:error, Castable.cast(Plaid.Error, %{})}
    end
  end

  def handle_response(res, _) do
    Logger.warn([
      "[#{__MODULE__}] un-",
      " un-handled response.",
      " #{inspect(res)}",
      " Create an issue or pull request with the above response",
      " at https://github.com/tylerwray/elixir-plaid."
    ])

    {:error, Castable.cast(Plaid.Error, %{})}
  end
end
