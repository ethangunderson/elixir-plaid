defmodule Plaid.Processor do
  @moduledoc """
  [Plaid Processor API](https://plaid.com/docs/api/processors) calls and schema.
  """

  alias Plaid.Castable

  defmodule CreateTokenResponse do
    @moduledoc """
    [Plaid API /processor/token/create response schema.](https://plaid.com/docs/api/processors/#processortokencreate)
    """

    @behaviour Castable

    @type t :: %__MODULE__{
            processor_token: String.t(),
            request_id: String.t()
          }

    defstruct [:processor_token, :request_id]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        processor_token: generic_map["processor_token"],
        request_id: generic_map["request_id"]
      }
    end
  end

  @doc """
  Creates a processor token from an access_token.

  Does a POST `/processor/token/create` call which generates
  any non-stripe processor token for a given account ID.

  Params:
  * `access_token` - access_token to create a processor token for.
  * `account_id` - ID of the account to create a processor token for.
  * `processor` - name of the processor to create a token for.

  ## Examples

      create_token("access-prod-123xxx", "blejdkalk3kdlsl", "galileo", client_id: "123", secret: "abc")
      {:ok, %CreateTokenResponse{}}

  """
  @spec create_token(String.t(), String.t(), String.t(), Plaid.config()) ::
          {:ok, CreateTokenResponse.t()} | {:error, Plaid.Error.t()}
  def create_token(access_token, account_id, processor, config) do
    Plaid.Client.call(
      "/processor/token/create",
      %{access_token: access_token, account_id: account_id, processor: processor},
      CreateTokenResponse,
      config
    )
  end

  defmodule CreateStripeBankAccountTokenResponse do
    @moduledoc """
    [Plaid API /processor/stripe/bank_account_token/create response schema.](https://plaid.com/docs/api/processors/#processorstripebank_account_tokencreate)
    """

    @behaviour Castable

    @type t :: %__MODULE__{
            stripe_bank_account_token: String.t(),
            request_id: String.t()
          }

    defstruct [:stripe_bank_account_token, :request_id]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        stripe_bank_account_token: generic_map["stripe_bank_account_token"],
        request_id: generic_map["request_id"]
      }
    end
  end

  @doc """
  Creates a stripe bank account token from an access_token.

  Does a POST `/processor/stripe/bank_account_token/create` call which
  generates a stripe bank account token for a given account ID.

  Params:
  * `access_token` - access_token to create a processor token for.
  * `account_id` - ID of the account to create a processor token for.

  ## Examples

      create_stripe_bank_account_token("access-prod-123xxx", "blejdkalk3kdlsl", client_id: "123", secret: "abc")
      {:ok, %CreateStripeBankAccountTokenResponse{}}

  """
  @spec create_stripe_bank_account_token(String.t(), String.t(), Plaid.config()) ::
          {:ok, CreateStripeBankAccountTokenResponse.t()} | {:error, Plaid.Error.t()}
  def create_stripe_bank_account_token(access_token, account_id, config) do
    Plaid.Client.call(
      "/processor/stripe/bank_account_token/create",
      %{access_token: access_token, account_id: account_id},
      CreateStripeBankAccountTokenResponse,
      config
    )
  end
end
