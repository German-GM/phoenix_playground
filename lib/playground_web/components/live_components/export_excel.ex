defmodule LynxwebWeb.LiveComponents.ExportExcel do
  @moduledoc """
    Este componente permite exportar datos a un archivo Excel directamente desde la interfaz de usuario. Es especialmente útil para tablas que no manejan filtros, pero que pueden tener o no paginación.
    los atributos que se necesitan al momento de usarlo son:

    - __file_name (string)__:
    Especifica el nombre del archivo Excel que será descargado por el usuario.
    Ejemplo: "reporte.xlsx".
    ---
    - __id_component (string o nil)__:
    Identificador único del componente, necesario para distinguir entre diferentes instancias del componente en una misma vista.
    Se utiliza para validar y relacionar eventos correctamente.
    ---
    - __data_to_export (lista o nil)__:
    Contiene los datos que serán exportados al archivo Excel.
    ---
    - __has_pagination (boolean)__:
    Indica si los datos están paginados.
    Si es true, el componente podrá implementar lógica para manejar la exportación de datos en múltiples páginas (pendiente de implementación).

  """

  use LynxwebWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:file_name, fn -> "" end)
      |> assign_new(:id_component, fn -> nil end)
      |> assign_new(:data_to_export, fn -> nil end)
      |> assign_new(:has_pagination, fn -> false end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.file_exporter
        :if={Enum.count(@data_to_export) > 0}
        id={"export-xlsx-#{@id_component}"}
        action={~p"/lynx/export_xlsx"}
        filename={"#{@file_name}"}
        btn_name="Exportar a Excel"
        phx-click="export-xlsx"
        phx-target={@myself}
        phx-value-id_component={@id_component}
        phx-hook="StopPropagationHook"
        styled_btn_icon="hero-document-text"
        styled_btn_color="secondary"
      />
    </div>
    """
  end

  def handle_event("export-xlsx", %{"id_component" => id_component}, socket) do
    Debug.print(socket.assigns, label: "socket.assigns")
    Debug.print(id_component, label: "id_component")
    id_socket = to_string(socket.assigns.id_component)

    if id_socket == id_component do
      has_pagination = socket.assigns.has_pagination
      data = socket.assigns.data_to_export

      socket =
        if has_pagination do
          # TODO: Implementar la lógica de exportación de archivos con paginación posteriormente cuando sea necesario
        else
          if data != [] || data != nil do
            socket
            |> push_event("export-file-payload-component", %{
              data: data,
              id_component: id_component
            })
          else
            socket
            |> push_event("toggle-file-export-loading", %{})
            |> put_flash(:error, "No se pudo exportar el archivo.")
          end
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
