defmodule LynxwebWeb.UserSocket do
  use Phoenix.Socket

  channel "theme:change", LynxwebWeb.ThemeChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
