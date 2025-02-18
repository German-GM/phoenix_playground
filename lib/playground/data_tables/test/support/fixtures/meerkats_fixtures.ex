#---
# Excerpted from "Building Table Views with Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/puphoe for more book information.
#---
defmodule Meow.MeerkatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Meow.Meerkats` context.
  """

  @doc """
  Generate a meerkat.
  """
  def meerkat_fixture(attrs \\ %{}) do
    {:ok, meerkat} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Meow.Meerkats.create_meerkat()

    meerkat
  end
end
