#---
# Excerpted from "Building Table Views with Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/puphoe for more book information.
#---
defmodule Meow.Meerkats.Meerkat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meerkats" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(meerkat, attrs) do
    meerkat
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
