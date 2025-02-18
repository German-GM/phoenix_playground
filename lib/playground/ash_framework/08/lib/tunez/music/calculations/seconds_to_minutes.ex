#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez/music/calculations/seconds_to_minutes.ex

# ------------------------------------------------------------------------------
# Context: Defining a calculation module to convert seconds to minutes+seconds
defmodule Tunez.Music.Calculations.SecondsToMinutes do
  use Ash.Resource.Calculation

  def calculate(tracks, _opts, _context) do
    # Code to calculate duration for each track in the list of tracks
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Filling in the behaviour of the calculation, to convert numbers like
# 125 into strings like "2:05"
def calculate(tracks, _opts, _context) do
  tracks
  |> Enum.map(fn %{duration_seconds: duration} ->
    seconds =
      rem(duration, 60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{div(duration, 60)}:#{seconds}"
  end)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Converting the calculation to use an expression
defmodule Tunez.Music.Calculations.SecondsToMinutes do
  use Ash.Resource.Calculation

  def expression(_opts, _context) do
    expr(
      fragment("? / 60 || to_char(? * interval '1s', ':SS')",
               duration_seconds, duration_seconds)
    )
  end
end
# ------------------------------------------------------------------------------
