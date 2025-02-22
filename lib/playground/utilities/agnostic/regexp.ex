defmodule Playground.Utilities.Agnostic.Regexp do
  @moduledoc """
  Módulo con funciones de expresiones regulares.
  """

  def more_than_one_space, do: ~r/\s{2,}/
  def blank_spaces, do: ~r/\s/
  def only_numbers, do: ~r/^\d+$/
  def only_letters, do: ~r/^[a-zA-ZñÑ\s]+$/
  def uuid, do: ~r/^[a-f0-9A-F]{8}-[a-f0-9A-F]{4}-[a-f0-9A-F]{4}-[a-f0-9A-F]{4}-[a-f0-9A-F]{12}$/
  def card_masked_pan, do: ~r/^(?=\d*X+\d*$).{16}$/
  def formatted_phone, do: ~r/\((\d{2,})\)(\d{3})-(\d{2})-(\d{2})/
  def name, do: ~r/^[A-Za-zÀ-ÖØ-öø-ÿáéíóúÁÉÍÓÚüÜ ]+$/
  def email, do: ~r/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
end
