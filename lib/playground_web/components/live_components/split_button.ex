defmodule LynxwebWeb.LiveComponents.SplitButton do
  use LynxwebWeb, :custom_live_component

  alias Lynxweb.Utilities.Agnostic.{Format, UIHelpers}

  @doc """
  Regresa un botón de despliegue con opciones de acción o redirección.

  ## Ejemplo

      <.split_button id="split-btn" icon="hero-plus" default_value="Acción consultar">
        <:option text="Acción imprimir" action="print" />
        <:option text="Acción consultar" action="query" />
        <:option text="Ir a Débito" navigate={~p"/debito"} />
        <:option icon="hero-arrow-right-on-rectangle" text="Logout" href={~p"/log_out"} method="delete" />
      </.split_button>
  """
  attr :id, :string, required: true
  attr :color, :string, values: ["primary", "secondary", "danger", "default"], default: "primary"
  attr :icon, :string, default: nil, doc: "Icono a mostrar junto al botón"
  attr :default_value, :string, default: nil, doc: "Opción predeterminada del botón, en relacion a la propiedad 'text' de la opción"

  slot :option do
    attr :icon, :string, doc: "Icono a mostrar junto a la opción"
    attr :text, :string, doc: "Texto de las opciones y del botón"
    attr :action, :string, doc: "Acción a realizar cuando se hace clic en la opción o en el botón, emite un handle_info {:split_btn_click, action}"
    attr :navigate, :string, doc: "Ruta a la que redireccionar cuando se hace clic en la opción o en el botón"
    attr :href, :string, doc: "URL a la que redireccionar cuando se hace clic en la opción o en el botón"
    attr :method, :any, doc: "Método a utilizar para la acción de redirección, utilizado con el atributo 'href'"
  end

  # El nombre de la función debe nombrarse igual que el nombre del módulo pero en formato snake_case
  # Ejemplo: "LynxwebWeb.LiveComponents.ModuloComponente", función: "modulo_componente(assigns)", html: <.modulo_componente />
  def split_button(assigns) do
    ~H"""
    <.live_component module={__MODULE__} {assigns_to_attributes(assigns)} />
    """
  end

  def mount(socket) do
    socket =
      assign(socket,
        current_focus: -1
      )

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = socket
    |> assign(assigns)

    socket = socket
    |> assign_new(:index, fn ->
      Enum.find_index(socket.assigns.option, fn option ->
        option[:text] == socket.assigns.default_value
      end) || 0
    end)

    socket = socket
    |> assign(
      option_btn: Enum.at(socket.assigns.option, socket.assigns.index, 0)
    )

    {:ok, socket}
  end

  def render(assigns) do

    ~H"""
    <div class="inline-flex rounded-md shadow-sm">
      <.link
        phx-click={@option_btn[:action] && JS.push("split_btn_click", value: %{action: @option_btn[:action], index: @index}, target: @myself)}
        navigate={@option_btn[:navigate]}
        href={@option_btn[:href]}
        method={@option_btn[:method]}
      >
        <.button
          color={@color}
          class="rounded-r-none whitespace-nowrap"
        >
          <.icon :if={@icon} name={@icon} class="mr-2" />
          <%= @option_btn[:text] %>
        </.button>
      </.link>
      <div class="relative -ml-px block">
        <.button
          phx-click={show_dropdown("##{@id}-splitbtn")}
          class="!px-2 rounded-l-none !border-l-primary-contrast/40"
          color={@color}
        >
          <.icon name="hero-chevron-down" />
        </.button>

        <div
          id={"#{@id}-splitbtn"}
          phx-click-away={hide_dropdown("##{@id}-splitbtn")}
          class={[
            "hidden absolute right-0 z-10 mt-2 w-56 origin-top-right divide-y divide-gray-100",
            "rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
          ]}
          role="menu"
          aria-labelledby={@id}
          phx-window-keydown="set-focus"
          phx-target={@myself}
        >
          <div :for={{option, idx} <- Enum.with_index(@option)} class="py-1" role="none">
            <.link
              id={"#{@id}-#{idx}"}
              tabindex="-1"
              role="menuitem"
              phx-click={option[:action] && JS.push("split_btn_click", value: %{action: option[:action], index: idx}, target: @myself) |> hide_dropdown("##{@id}-splitbtn")}
              class={"text-gray-700 hover:bg-primary-subtle group flex items-center px-4 py-2 text-sm #{if @index == idx, do: "bg-gray-200"}"}
              navigate={option[:navigate]}
              href={option[:href]}
              method={option[:method]}
            >
              <.icon :if={option[:icon]} name={option[:icon]} class="mr-2" />
              <%= option[:text] %>
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("split_btn_click", map, socket) do
    send(self(), {:split_btn_click, map["action"]})

    index = map["index"] |> Format.try_parse_string_to_integer()
    option_btn = Enum.at(socket.assigns.option, index, 0)

    socket = socket
    |> assign(
      index: index,
      option_btn: option_btn
    )

    {:noreply, socket}
  end

  def handle_event("set-focus", %{"key" => "Enter"}, socket) do
    id = socket.assigns.id
    index = socket.assigns.index

    socket = UIHelpers.trigger_click(socket, "#{id}-#{index}")
    {:noreply, socket}
  end

  def handle_event("set-focus", %{"key" => "ArrowUp"}, socket) do
    index =
      Enum.max([(socket.assigns.index - 1), 0])

    {:noreply, assign(socket, index: index)}
  end

  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    index =
      Enum.min([(socket.assigns.index + 1), (length(socket.assigns.option) - 1)])

    {:noreply, assign(socket, index: index)}
  end

  def handle_event("set-focus", _, socket), do: {:noreply, socket}
end
