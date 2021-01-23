defmodule Plaid.Categories do
  @moduledoc """
  [Plaid Categories API](https://plaid.com/docs/api/products/#categoriesget) calls and schema.
  """

  @type t :: %__MODULE__{
          categories: list(Plaid.Categories.Category.t()),
          request_id: String.t()
        }

  defstruct [
    :categories,
    :request_id
  ]

  @doc """
  Get information about all Plaid categories

  Does a `POST /categories/get` call to retrieve a list of all categories.

  ## Example

      get(client_id: "123", secret: "abc")
      {:ok, %Plaid.Categories{}}

  """
  @spec get(Plaid.config()) :: {:ok, t()} | {:error, Plaid.Error.t()}
  def get(config) do
    Plaid.Client.call(
      "/categories/get",
      %{},
      __MODULE__,
      config
    )
  end
end
