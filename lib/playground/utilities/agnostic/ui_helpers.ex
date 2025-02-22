defmodule Playground.Utilities.Agnostic.UIHelpers do
  @moduledoc """
  Módulo con utilidades reusables para liveviews y componentes.
  """

  def focus_input(socket, id) do
    socket |> Phoenix.LiveView.push_event("trigger-event-by-id", %{id: id, event_type: "focus"})
  end

  def trigger_click(socket, id) do
    socket |> Phoenix.LiveView.push_event("trigger-event-by-id", %{id: id, event_type: "click"})
  end

  def disabled_button(socket, id, disabled) do
    socket |> Phoenix.LiveView.push_event("disabled-by-id", %{id: id, disabled: disabled})
  end

  def reset_input(socket, id) do
    socket |> Phoenix.LiveView.push_event("reset-input-by-id", %{id: id})
  end

  @doc """
  Agrega una estrucutra Phoneix.HTML.Form al socket con un nombre especificado o con el nombre default ":form" si no se establece, para ser utilizado en componentes `<.form />` o `<.simple_form />`

  Puede aceptar un Mapa o un Struct (ej. un Changeset)

  Ejemplos:

  - UIHelpers.assign_form(socket, `%{}`)
  - UIHelpers.assign_form(socket, `%User{}`)
  - UIHelpers.assign_form(socket, %{}, `:login_form`)
  - UIHelpers.assign_form(socket, %User{}, `:register_form`)
  """
  @spec assign_form(Phoenix.LiveView.Socket.t(), map() | struct(), atom()) ::
          Phoenix.LiveView.Socket.t()
  def assign_form(socket, %{} = map, atom_form_name \\ :form) do
    Phoenix.Component.assign(socket, atom_form_name, Phoenix.Component.to_form(map))
  end
end
