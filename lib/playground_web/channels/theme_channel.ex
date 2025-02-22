defmodule LynxwebWeb.ThemeChannel do
  use Phoenix.Channel

  def join("theme:change", _message, socket) do
    {:ok, socket}
  end

  # Manejar mensajes enviados desde el cliente
  def handle_in("theme_change_from_client", %{"new_theme" => _theme}, socket) do
    # broadcast(socket, "theme_change_from_server", %{new_theme: _theme})
    {:noreply, socket}
  end
end
