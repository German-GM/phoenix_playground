#---
# Excerpted from "Building Table Views with Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/puphoe for more book information.
#---
defmodule MeowWeb.Forms.SortingFormTest do
  use Meow.DataCase, async: true

  alias MeowWeb.Forms.SortingForm

  @default_params %{
    "sort_by" => "name",
    "sort_dir" => "desc"
  }

  describe "parse/1" do
    test "parses all fields correctly" do
      {:ok, params} = SortingForm.parse(@default_params)
      assert params.sort_by == :name
      assert params.sort_dir == :desc
    end

    test "validates the fields" do
      assert {:ok, _params} = SortingForm.parse(@default_params)

      assert {:error, _changeset} =
               @default_params |> Map.merge(%{"sort_by" => "foo"}) |> SortingForm.parse()

      assert {:error, _changeset} =
               @default_params |> Map.merge(%{"sort_dir" => "foo"}) |> SortingForm.parse()
    end
  end
end
