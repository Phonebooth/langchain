defmodule LangChain.Message.MessagePart do
  @moduledoc """
  Models a `MessagePart`. Some LLMs support combining text, images, and possibly
  other content as part of a single message. A `MessagePart` represents a block,
  or part, of a message's content that is all of one type.

  ## Types

  - `:text` - The message part is text.

  - `:image_url` - The message part is a URL to an image.

  - `:image` - The message part is image data that is base64 encoded text.

  """
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias __MODULE__
  alias LangChain.LangChainError

  @primary_key false
  embedded_schema do
    field :type, Ecto.Enum, values: [:text, :image_url, :image], default: :text
    field :content, :string
  end

  @type t :: %MessagePart{}
  # @type type :: :text | :image_url | :image

  @update_fields [:type, :content]
  @create_fields @update_fields
  @required_fields [:type, :content]

  @doc """
  Build a new message and return an `:ok`/`:error` tuple with the result.
  """
  @spec new(attrs :: map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs \\ %{}) do
    %MessagePart{}
    |> cast(attrs, @create_fields)
    |> common_validations()
    |> apply_action(:insert)
  end

  @doc """
  Build a new message and return it or raise an error if invalid.
  """
  @spec new!(attrs :: map()) :: t() | no_return()
  def new!(attrs \\ %{}) do
    case new(attrs) do
      {:ok, message} ->
        message

      {:error, changeset} ->
        raise LangChainError, changeset
    end
  end

  @doc """
  Create a new MessagePart that contains text. Raises an exception if not valid.
  """
  @spec text!(String.t()) :: t() | no_return()
  def text!(content) do
    new!(%{type: :text, content: content})
  end

  @doc """
  Create a new MessagePart that contains an image encoded as base64 data. Raises
  an exception if not valid.
  """
  @spec image!(String.t()) :: t() | no_return()
  def image!(content) do
    new!(%{type: :image, content: content})
  end

  @doc """
  Create a new MessagePart that contains a URL to an image. Raises an exception if not valid.
  """
  @spec image_url!(String.t()) :: t() | no_return()
  def image_url!(content) do
    new!(%{type: :image_url, content: content})
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, @update_fields)
    |> common_validations()
  end

  defp common_validations(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
