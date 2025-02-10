#---
# Excerpted from "Real-World Event Sourcing",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/khpes for more book information.
#---
defmodule EventSourcedCalculator.V3 do
  @moduledoc """
  cmds = [%{cmd: :add, value: 10}, %{cmd: :add, value: 50}, %{cmd: :div, value: 0}, %{cmd: :add, value: 2}]
  initial = %{value: 0}
  cmds |> List.foldl(initial, fn cmd, acc -> EventSourcedCalculator.V3.handle_event(acc, EventSourcedCalculator.V3.handle_command(acc,cmd)) end)
  """

  @max_state_value 10_000
  @min_state_value 0

  def handle_command(%{value: val}, %{value: v, cmd: :add}) do
    %{event_type: :value_added,
      value: min(@max_state_value - val, v)}
  end

  def handle_command(%{value: val}, %{value: v, cmd: :sub}) do
    %{event_type: :value_subtracted,
      value: max(@min_state_value, val - v)}
  end

  def handle_command(
        %{value: val},
        %{cmd: :mul, value: v}
      )
      when val * v > @max_state_value do
    {:error, :mul_failed}
  end

  def handle_command(%{value: _val}, %{cmd: :mul, value: v}) do
    %{event_type: :value_multiplied, value: v}
  end

  def handle_command(
        %{value: _val},
        %{cmd: :div, value: 0}
      ) do
    {:error, :divide_failed}
  end

  def handle_command(%{value: _val}, %{cmd: :div, value: v}) do
    %{event_type: :value_divided, value: v}
  end

  def handle_event(
        %{value: val},
        %{event_type: :value_added, value: v}
      ) do
    %{value: val + v}
  end

  def handle_event(
        %{value: val},
        %{event_type: :value_subtracted, value: v}
      ) do
    %{value: val - v}
  end

  def handle_event(
        %{value: val},
        %{event_type: :value_multiplied, value: v}
      ) do
    %{value: val * v}
  end

  def handle_event(
        %{value: val},
        %{event_type: :value_divided, value: v}
      ) do
    %{value: val / v}
  end

  def handle_event(%{value: _val} = state, _) do
    state
  end
end
