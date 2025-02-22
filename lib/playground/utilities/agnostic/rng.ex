defmodule Playground.Utilities.Agnostic.RNG do
  def generate_id(bytes \\ 16) do
    :crypto.strong_rand_bytes(bytes)
    |> Base.encode16()
    |> String.downcase()
    |> String.replace("+", "-")
    |> String.replace("/", "_")
    |> String.replace("\n", "")
  end

  def system_unique_id() do
    System.unique_integer([:positive])
  end

  def generate_number(length) when is_integer(length) and length > 0 do
    numbers = Enum.map(1..length, fn _ -> :rand.uniform(10) - 1 end)
    numbers
    |> Enum.join()
    |> String.to_integer()
  end
end
