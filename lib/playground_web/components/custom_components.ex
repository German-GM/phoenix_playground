defmodule LynxwebWeb.CustomComponents do
  @moduledoc """
  Provides custom UI components.

  The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns based on the current
  application growth and needs.

  Refs:
  https://tailwindcss.com - A utility-first CSS framework
  https://heroicons.com - See `icon/1` in the "core_components.ex" file for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import LynxwebWeb.CoreComponents, only: [icon: 1, error: 1, button: 1, card: 1, spinner: 1]

  attr :errors, :any, default: ""
  attr :label, :string, default: ""
  attr :show_icon, :boolean, default: true
  attr :class, :string, default: nil
  attr :hide, :boolean, default: false

  # Manejar errores en formato de lista de tuplas
  def print_error(assigns)
      when is_list(assigns.errors) and length(assigns.errors) > 0 and is_tuple(hd(assigns.errors)) do
    ~H"""
    <div class={@class} style={"#{if @hide, do: "display: none;"}"}>
      <%= for {_field, {message, _opts}} <- @errors do %>
        <.error
          show_icon={@show_icon}
          class="print_error_component !m-0 !leading-4 !flex !items-center"
        >
          <%= @label %>  <%= message %>
        </.error>
      <% end %>
    </div>
    """
  end

  def print_error(assigns)
      when is_list(assigns.errors) and length(assigns.errors) > 0 do
    ~H"""
    <div class={@class} style={"#{if @hide, do: "display: none;"}"}>
      <.error
        :if={@errors}
        show_icon={@show_icon}
        class="print_error_component !m-0 !leading-4 !flex !items-center"
      >
        <%= @label %>
        <%= Enum.join(@errors, ", ") %>
      </.error>
    </div>
    """
  end

  def print_error(assigns)
      when is_binary(assigns.errors) and assigns.errors != "" do
    ~H"""
    <div class={@class} style={"#{if @hide, do: "display: none;"}"}>
      <.error
        :if={@errors}
        show_icon={@show_icon}
        class="print_error_component !m-0 !leading-4 !flex !items-center"
      >
        <%= @label %>
        <%= @errors %>
      </.error>
    </div>
    """
  end

  def print_error(assigns) do
    ~H"""
    <span class="hidden"></span>
    """
  end

  @doc """
  Returns a button_group with clickable buttons, depends on a server event to manage its state

  Attributes:

    * `:group_class` - The class to apply to the button group container
    * `:btn_class` - The class to apply to each button
    * `:active_btn` - The active button
    * `:rest` - The arbitrary HTML attributes to apply to the button tag

  Slots:

    * `:button` - The buttons to display as a group

  ## Examples

  <form phx-submit="submit_form">
    <div class="flex items-center justify-center space-x-3">
      <div>
        <.button_group phx-click="btngroup_click" active_btn={@selected_option}>
          <:button icon="hero-user-solid" value="# Socio"> # Socio </:button>
          <:button icon="hero-identification-solid" value="Nombre"> Nombre </:button>
          <:button icon="hero-credit-card-solid" value="Tarjeta"> Tarjeta </:button>
        </.button_group>
      </div>
      <.input type="hidden" name="selected_option" value={@selected_option} />
      <.input autofocus id="search" type="text" name="search" value="" placeholder={@selected_option} class="basis-1/3" />
    </div>
  </form>

  def mount(_params, _session, socket) do
    {:ok, assign(socket, selected_option: "# Socio")}
  end

  def handle_event("btngroup_click", %{"value" => value}, socket) do
    {:noreply,
      socket
      |> push_event("focus_by_id", %{id: "search"})
      |> assign(selected_option: value)
    }
  end
  """
  attr :group_class, :string, default: nil
  attr :btn_class, :string, default: nil
  attr :active_btn, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global, doc: "the arbitrary HTML attributes to apply to the button tag"

  slot :button do
    attr :icon, :string
    attr :value, :string
    attr :title, :string
  end

  def button_group(assigns) do
    ~H"""
    <span class={["isolate inline-flex rounded-md bg-app", @group_class]} style="padding: 2px;">
      <button
        :for={button <- @button}
        type="button"
        disabled={@disabled}
        class={[
          "#{if @active_btn == button[:value], do: "!text-gray-700 bg-white rounded-md shadow shadow-slate-300"}",
          "transition-all transform ease-out duration-75 relative inline-flex items-center px-4 text-sm py-[9px]",
          "text-gray-500 font-medium whitespace-nowrap",
          @btn_class
        ]}
        title={button[:title]}
        value={button[:value]}
        {@rest}
      >
        <.icon :if={button[:icon]} name={button[:icon]} class="mr-2 -ml-1" />
        <%= render_slot(button) %>
      </button>
    </span>
    """
  end

  @doc """
  Returns a tab_menu with clickable tabs that show the contents of each.

  Attributes:

    * `:id` - The id to uniquely identify this tab_menu
    * `:class` - Optional additional classes to apply
    * `:cols` - The number of columns in the menu items

  Slots:

    * `:tab` - The tab button with a title attribute, and the content of the tab between the opening and closing tag

  ## Examples

      <.tab_menu id="nav" class="relative">
        <:tab title="Tab 1">
          Tab content 1
        </:tab>
        <:tab title="Tab 2">
          Tab content 2
        </:tab>
      </.tab_menu>
  """
  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :cols, :string, default: "4"

  slot :tab do
    attr :title, :string
  end

  def tab_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="TabManager"
      class={[
        "flex h-full z-10",
        @class
      ]}
    >
      <div class="flex h-full space-x-8">
        <div :for={{tab, i} <- Enum.with_index(@tab)} class="flex">
          <div class="relative flex">
            <!-- Item active: "border-indigo-600 text-indigo-600", Item inactive: "border-transparent text-gray-700 hover:text-gray-800" -->
            <button type="button" class="tab-hook tab-btn px-1 pt-1" aria-expanded="false" data-tab={"#{@id}-tab-#{i}"}>
              <%= tab[:title] || "no_title" %>
            </button>
          </div>
          <!--
            Entering: "transition ease-out duration-200"
              From: "opacity-0"
              To: "opacity-100"
            Leaving: "transition ease-in duration-150"
              From: "opacity-100"
              To: "opacity-0"
          -->
          <div
            id={"#{@id}-tab-#{i}"}
            class="content-hook tab-content hidden absolute inset-x-0 top-full text-gray-500 sm:text-sm"
          >
            <!-- Presentational element used to render the bottom shadow, if we put the shadow on the actual panel it pokes out the top, so we use this shorter element to hide the top of the shadow -->
            <div class="absolute inset-0 top-1/2 bg-white shadow" aria-hidden="true"></div>
            <div class="relative bg-white">
              <div class="mx-auto max-w-screen-2xl px-4 sm:px-6 lg:px-8">
                <div class="grid grid-cols-1 items-start gap-x-8 gap-y-10 pb-12 pt-10">
                  <div
                    class="grid gap-x-8 gap-y-10"
                    style={"grid-template-columns: repeat(#{@cols}, minmax(0, 1fr))"}
                  >
                    <%= render_slot(tab) %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Returns a tabs with clickable tabs that show the contents of each.

  Attributes:

    * `:id` - The id to uniquely identify this tabs
    * `:active` - Optional, the active tab index, defaults to 0
    * `:class` - Optional additional classes to apply

  Slots:

    * `:tab` - The tab button with a title attribute, and the content of the tab between the opening and closing tag

  ## Examples

  ### Default

      <.tabs id="tab-example" active="0">
        <:tab title="Tab 1">
          Tab content 1
        </:tab>
        <:tab title="Tab 2">
          Tab content 2
        </:tab>
      </.tabs>

  ### Navigation

      <.tabs id="tab-example" type="navigation" active="0">
        <:tab title="Tab 1" navigate={~p"/embozado"} />
        <:tab title="Tab 2" navigate={~p"/debito"} />
      </.tabs>
  """

  attr :id, :string, required: true
  attr :type, :string, values: ["navigation", nil], default: nil
  attr :active, :string, default: "0", doc: "El índice del tab activo inicial con su contenido visible"
  attr :position, :string, values: ["left", "center", "right"], default: "left", doc: "Posición del grupo de tabs"
  attr :border_bottom, :boolean, default: false, doc: "true: borde inferior visible"

  slot :tab do
    attr :title, :string
    attr :navigate, :string
  end

  def tabs(%{type: "navigation"} = assigns) do
    position = case assigns.position do
      "center" -> "justify-center"
      "right" -> "justify-end"
      _ -> "justify-start"
    end

    assigns = assign(assigns, position: position)

    ~H"""
    <div class={"flex #{@position} #{if @border_bottom, do: "border-b border-gray-200", else: ""}"}>
      <!-- Item active: "border-indigo-600 text-indigo-600", Item inactive: "border-transparent text-gray-700 hover:text-gray-800" -->
      <div :for={{tab, i} <- Enum.with_index(@tab)}>
        <.link navigate={tab[:navigate]}>
          <button
            class={"tab-btn p-4 px-6 #{if "#{@active}" == "#{i}", do: "active"}"}
            aria-expanded="false"
          >
            <%= tab[:title] || "no_title" %>
          </button>
        </.link>
      </div>
    </div>
    """
  end

  def tabs(assigns) do
    position = case assigns.position do
      "center" -> "justify-center"
      "right" -> "justify-end"
      _ -> "justify-start"
    end

    assigns = assign(assigns, position: position)

    ~H"""
    <div
      id={@id}
      phx-hook="TabManager"
      data-tabs-component={"true"}
    >
      <div>
        <div class={"flex #{@position} #{if @border_bottom, do: "border-b border-gray-200", else: ""}"}>
          <!-- Item active: "border-indigo-600 text-indigo-600", Item inactive: "border-transparent text-gray-700 hover:text-gray-800" -->
          <button
            :for={{tab, i} <- Enum.with_index(@tab)}
            class={"#{@id}-tab-hook tab-btn p-4 px-6 #{if "#{@active}" == "#{i}", do: "active"}"}
            aria-expanded="false"
            data-tab={"#{@id}-tab-#{i}"}
          >
            <%= tab[:title] || "no_title" %>
          </button>
        </div>
        <!--
          Entering: "transition ease-out duration-200"
            From: "opacity-0"
            To: "opacity-100"
          Leaving: "transition ease-in duration-150"
            From: "opacity-100"
            To: "opacity-0"
        -->
        <div
          id={"#{@id}-tab-#{i}"}
          :for={{tab, i} <- Enum.with_index(@tab)}
          class={"#{@id}-content-hook tab-content text-gray-700 pt-6 #{if "#{@active}" == "#{i}", do: "", else: "hidden"}"}
        >
          <%= render_slot(tab) %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Componente para mostrar elementos con una estructura tipo acordeón.
  'accordion_container' se puede anidar sin restricciones.

  <.accordion_container id="accordion-container1">
    <:accordion
      name="1er acordeón"
    >
      Contenido 1
    </:accordion>
    <:accordion
      name="2do acordeón"
    >
      Contenido 2
    </:accordion>
  </.accordion_container>
  """

  attr :id, :string,
    required: true,
    doc: "El identificador principal del contenedor, sirve para agrupar y manejar los acordeones"

  attr :multiple, :boolean,
    default: true,
    doc: "Permite abrir/cerrar multiples acordeones sin restriccion. Es el comportamiento default"

  attr :only_one, :boolean, default: false, doc: "Permite abrir un acordeon a la vez (por grupo)"

  attr :open_all, :boolean,
    default: false,
    doc: "Se abriran todos los acordeones al montarse el componente"

  attr :open_default, :any,
    default: nil,
    doc:
      "Se abrira solo el acordeon con el identificador indicado, o bien, el primero si se pasa como booleano"

  attr :accordion_height, :string, default: "64px"

  slot :accordion do
    attr :name, :string
    attr :class, :string
  end

  def accordion_container(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Accordion"
      data-multiple={"#{@multiple}"}
      data-only-one={"#{@only_one}"}
      data-open-all={"#{@open_all}"}
      data-open-default={"#{@open_default}"}
    >
      <.card
        :for={{acc, i} <- Enum.with_index(@accordion)}
        root_class="overflow-clip"
        class="whitespace-nowrap !p-0 mt-2"
      >
        <button
          data-id={"#{@id}-#{i}"}
          data-header-name={acc[:name]}
          style={"height: #{@accordion_height};"}
          class={[
            "w-full text-left px-8 flex items-center bg-primary-subtle-light hover:bg-primary-subtle transition-colors border-gray-100",
            "#{@id}-lynxweb-accordion-header",
            acc[:class]
          ]}
        >
          <div class="grow font-medium text-xl">
            <%= acc[:name] %>
          </div>
          <.icon name="hero-chevron-down" class="transition-transform duration-200 ease-out" />
        </button>

        <div
          data-id={"#{@id}-#{i}"}
          class={[
            "accordion-close p-2 transition-all duration-100 ease-out",
            "#{@id}-lynxweb-accordion-container"
          ]}
        >
          <%= render_slot(acc) %>
        </div>
      </.card>
    </div>
    """
  end

  @doc """
  Componente para mostrar elementos con una estructura de menús con submenús, comparte el hook 'Accordion' del componente 'accordion_container'.
  Se utiliza en conjunto con el componente 'tree_view_item' para darle un estilo consistente a los elementos.
  'tree_view_container' se puede anidar sin restricciones.

  <.tree_view_container id="container">
    <:accordion name="Item desplegable 1" icon="hero-user-group text-blue-500">
      <.tree_view_item
        name="Item 1"
      />
      <.tree_view_item
        name="Item 2"
      />
    </:accordion>
  </.tree_view_container>

  <.tree_view_item
    name="Item 3"
  />
  <.tree_view_item
    name="Item 4"
  />
  """
  attr :id, :string,
    required: true,
    doc: "El identificador principal del contenedor, sirve para agrupar y manejar los tree views"

  attr :multiple, :boolean,
    default: true,
    doc: "Permite abrir/cerrar multiples tree views sin restriccion. Es el comportamiento default"

  attr :open_default, :any,
    default: nil,
    doc:
      "Se abrira solo el acordeon con el identificador indicado, o bien, el primero si se pasa como booleano"

  slot :accordion do
    attr :name, :string
    attr :icon, :string
    attr :class, :string
  end

  def tree_view_container(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Accordion"
      data-multiple={"#{@multiple}"}
      data-open-default={"#{@open_default}"}
    >
      <div
        :for={{accordion, i} <- Enum.with_index(@accordion)}
        root_class="overflow-clip"
        class="whitespace-nowrap !p-0 mt-2"
      >
        <span
          data-id={"#{@id}-#{i}"}
          data-header-name={accordion[:name]}
          class={[
            "#{@id}-lynxweb-accordion-header cursor-pointer",
            accordion[:class]
          ]}
        >
          <.icon :if={accordion[:icon]} name={accordion[:icon]} />
          <span class="grow text-md">
            <%= accordion[:name] %>
          </span>
          <.icon name="hero-chevron-down" class="transition-transform duration-200 ease-out" size="16px" />
        </span>

        <div
          data-id={"#{@id}-#{i}"}
          class={[
            "accordion-close pl-7 transition-all duration-100 ease-out",
            "#{@id}-lynxweb-accordion-container"
          ]}
        >
          <%= render_slot(accordion) %>
        </div>
      </div>
    </div>
    """
  end

  @doc"""
  Componente pensado para utilizarse en conjunto con el componente 'tree_view_container' (ver doc. de ese componente)
  """
  attr :name, :string, required: true
  attr :icon, :string, default: nil
  attr :class, :string, default: nil
  attr :phx_click, :string, default: nil
  attr :active, :string, default: ""
  attr :click_data, :string, default: nil, doc: "Si este atributo no se asigna, se usará el atributo name como dato obtenido del evento click"

  def tree_view_item(assigns) do
    ~H"""
    <div
      class={["mt-2 cursor-pointer flex items-center space-x-2 #{if @active in [@name, @click_data], do: "font-bold"}", @class]}
      phx-click={@phx_click}
      phx-value-data={@click_data || @name}
    >
      <.icon :if={@icon} name={@icon} />
      <span><%= @name %></span>
    </div>
    """
  end

  @doc"""
  Componente para facilitar la estructura de datos para representar gráficos con la librería Apache Echarts
  """
  attr :id, :string, required: true
  attr :height, :string, default: "720px"
  attr :margin_bottom, :string, default: "0px"

  slot :inner_block, required: true

  def apache_chart(assigns) do
    ~H"""
    <div id={@id} phx-hook="Chart">
      <div
        id={"#{@id}-chart"}
        style={[
          "height: #{@height};",
          "margin-bottom: #{@margin_bottom};"
        ]}
        phx-update="ignore"
      />

      <div
        id={"#{@id}-data"}
        hidden
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :title, :string, default: "Copiar"
  attr :copy_message, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def text_copy(assigns) do
    ~H"""
    <div class={["relative", @class]}>
      <div id={@id} title={@title} class="cursor-pointer" phx-hook="CopyText">
        <%= render_slot(@inner_block) %>
      </div>

      <div
        id={"copied_message_#{@id}"}
        class="z-10 w-max font-bold bg-primary text-primary-contrast rounded-md hidden absolute top-0"
      >
        <%= if @copy_message do %>
          <div class="px-2 m-auto">
            <%= @copy_message %>
          </div>
        <% else %>
          <.icon name="hero-clipboard-document-check" size="22px" />
        <% end %>
      </div>
    </div>
    """
  end

  attr :home_route, :string, default: "/landing"

  def breadcrumb_navigator(assigns) do
    ~H"""
    <.card class="!p-0" root_class="!shadow-none">
      <nav aria-label="Breadcrumb">
        <ol
          id="breadcrumbs-container"
          phx-hook="Breadcrumbs"
          role="list"
          class="overflow-clip flex h-0 opacity-0 w-full max-w-screen-xl space-x-4 px-6 transition-all duration-200 ease-out"
        >
          <li class="flex">
            <div class="flex items-center">
              <.link
                navigate={"#{@home_route}"}
                class="text-gray-500 hover:text-gray-800 transition-colors duration-200 ease-out"
                title="Ir al inicio"
              >
                <.icon name="hero-home-solid" />
                <span class="sr-only">
                  Inicio
                </span>
              </.link>
            </div>
          </li>
        </ol>
      </nav>
    </.card>
    """
  end

  attr :id, :string, required: true
  attr :data, :list, default: [], doc: "La lista de datos a exportar"
  attr :action, :string, required: true, doc: "La accion del form de este componente, e.g. ~p'/export_xlsx'"
  attr :method, :string, default: "post"
  attr :filename, :string, default: "exported_data"
  attr :btn_name, :string, default: "Exportar a XLSX"
  attr :styled_btn_icon, :string, default: nil, doc: "Cambia el estilo a botón y establece el icono en la parte izquierda del botón"
  attr :styled_btn_color, :string, default: nil, doc: "Cambia el estilo a botón y stablece el color del botón"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(class)

  def file_exporter(assigns) do
    assigns = assign(assigns, styled_btn: assigns.styled_btn_icon || assigns.styled_btn_color)

    ~H"""
    <.form
      id={@id}
      action={@action}
      phx-hook="ExportFileForm"
      phx-update="ignore"
      class={["inline-block min-w-fit", @class]}
      {@rest}
    >
      <%!-- <input name="_csrf_token" type="hidden" value={Plug.CSRFProtection.get_csrf_token()} /> --%>
      <input :if={length(@data) > 0} name="data" type="hidden" value={Jason.encode!(@data)} />
      <input name="filename" type="hidden" value={@filename} />

      <.button :if={@styled_btn} id={"#{@id}-btn"} class="whitespace-nowrap" style="width: inherit;" type="submit" color={@styled_btn_color}>
        <.icon :if={@styled_btn_icon} name={@styled_btn_icon} />
        <%= @btn_name %>
        <.spinner
          id={"#{@id}-spinner"}
          class="hidden absolute top-[50%] -translate-y-[50%] right-0 left-0"
          size="24px"
        />
      </.button>

      <button
        :if={!@styled_btn}
        id={"#{@id}-btn"}
        class="relative text-sm link-style"
        type="submit"
      >
        <%= @btn_name %>
        <.spinner
          id={"#{@id}-spinner"}
          class="hidden absolute top-[50%] -translate-y-[50%] right-0 left-0"
          size="24px"
        />
      </button>
    </.form>
    """
  end

  slot :inner_block, required: true

  def bloqueador_component(assigns) do
    ~H"""
    <div class="relative z-10">
      <!-- Modal centrado -->
      <div class="fixed inset-0 z-50 flex justify-center items-center">
        <div class="bg-white p-4 rounded-lg shadow-lg">
          <div class="text-black mb-4 flex flex-col items-center justify-center">
            <%= render_slot(@inner_block) %>
          </div>
        </div>
      </div>
      <!-- Bloqueador -->
      <div class="fixed top-0 left-0 w-full h-full bg-black bg-opacity-50 z-40 flex justify-center items-center">
        <div class="text-white">
          Cargando...
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :checked, :boolean, default: false
  attr :label, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  def switch(assigns) do
    ~H"""
    <div>
      <label class="flex items-center gap-2 text-md leading-6 text-zinc-600">
        <button
          id={@id}
          type="button"
          role="switch"
          value={"#{@checked}"}
          class={[
            "custom-switch relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full",
            "border-2 border-transparent transition-colors duration-200 ease-in-out",
            "#{if @checked, do: "bg-primary disabled:bg-primary-subtle", else: "bg-gray-200 disabled:bg-gray-100"}"
          ]}
          {@rest}
        >
          <span
            class={[
              "pointer-events-none inline-block h-5 w-5 transform rounded-full",
              "bg-white shadow ring-0 transition duration-200 ease-in-out",
              "#{if @checked, do: "translate-x-5", else: "translate-x-0"}"
            ]}
          />
        </button>

        <%= @label %>
      </label>

      <input type="hidden" name={@name} value={"#{@checked}"} />
    </div>
    """
  end

  attr :src, :string, default: ""
  attr :class, :string, default: nil

  def app_logo(assigns) do
    ~H"""
    <img data-logo class={@class} src={@src} alt="app_logo">
    """
  end

  def show_dropdown(js \\ %JS{}, to) do
    js
    |> JS.show(
      to: to,
      transition:
        {"transition ease-out duration-120", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: to)
  end

  def hide_dropdown(js \\ %JS{}, to) do
    js
    |> JS.hide(
      to: to,
      transition:
        {"transition ease-in duration-120", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: to)
  end
end
