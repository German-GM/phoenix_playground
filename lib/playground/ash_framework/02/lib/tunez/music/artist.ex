#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Adding a relationship from artist -> album
relationships do
  has_many :albums, Tunez.Music.Album
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a rsort for the albums relatinoship
relationships do
  has_many :albums, Tunez.Music.Album do
    sort year_released: :desc
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining a new attribute for `previous_names`
attributes do
  # ...
  attribute :previous_names, {:array, :string} do
    default []
  end
  # ...
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining a change to be run whenever the `update` action is called
actions do
  # ...
  update :update do
    accept [:name, :biography]

    change fn changeset, _context ->
      changeset
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding logic to the change, for storing an artist's previous names
change fn changeset, _context ->
         new_name = Ash.Changeset.get_attribute(changeset, :name)
         previous_name = Ash.Changeset.get_data(changeset, :name)
         previous_names = Ash.Changeset.get_data(changeset, :previous_names)

         names =
           [previous_name | previous_names]
           |> Enum.uniq()
           |> Enum.reject(fn name -> name == new_name end)

         Ash.Changeset.change_attribute(changeset, :previous_names, names)
       end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a condition for when the change function should run
change fn changeset, _context ->
         # ...
       end,
       where: [changing(:name)]
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using `require_atomic? false` to allow imperative code to be run in changes
update :update do
  require_atomic? false

  # ...
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Extracting out the change function into a reusable change module
update :update do
  require_atomic? false
  accept [:name, :biography]

  change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
end
# ------------------------------------------------------------------------------
