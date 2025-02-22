defmodule LynxwebWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import LynxwebWeb.Gettext

  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :message, :string, default: nil
  attr :full_screen, :boolean, default: false
  attr :size, :string, default: "32px"

  def spinner(assigns) do
    ~H"""
    <div id={@id} class={["text-center space-y-2 items-center", @class]}>
      <%= if @full_screen do %>
        <.backdrop>
          <.spinner_svg message={@message} size={@size} />
        </.backdrop>
      <% else %>
        <.spinner_svg message={@message} size={@size} />
      <% end %>
    </div>
    """
  end

  attr :message, :string, default: nil
  attr :size, :string, default: "32px"

  def spinner_svg(assigns) do
    ~H"""
    <div>
      <svg
        class="inline-block animate-spin text-gray-400 w-8"
        style={"width: #{@size}; height: #{@size};"}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        aria-hidden="true"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
        </circle>
        <path
          class="opacity-90"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        >
        </path>
      </svg>
    </div>

    <div :if={@message} class="text-slate-500 mt-2">
      <%= @message %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :bg_class, :string, default: "bg-white/90"
  slot :inner_block, required: true

  def backdrop(assigns) do
    ~H"""
    <div class={["fixed inset-0 z-50 #{@bg_class}", @class]}>
      <div class="absolute left-[50%] top-[50%] translate-x-[-50%] translate-y-[-50%]">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a container with a card-like style

  Attributes:

    * `:class` - The class to apply to the container

  Slots:

    * `:inner_block` - The content of the container

  ## Examples

  <.card class="">
    // card_content
  </.card>
  """
  attr :id, :string, default: nil
  attr :loading, :boolean, default: false
  attr :loading_message, :string, default: ""
  attr :root_class, :string, default: nil
  attr :class, :string, default: nil
  attr :title, :string, default: nil, doc: "Título del encabezado"
  attr :subtitle, :string, default: nil, doc: "Subtitulo del encabezado"
  attr :header_color, :string, default: "bg-gray-200", doc: "Color de fondo del encabezado"

  attr :header_font_size, :string,
    values: ["base", "lg", "xl"],
    default: "base",
    doc: "Tamaño de las fuentes de título y subtitulo"

  attr :filled_card_header, :boolean,
    default: false,
    doc: "true: Variante de header en donde se rellena todo el ancho con un color de fondo"

  attr :rest, :global

  slot :inner_block, required: true

  slot :header_action,
    default: nil,
    doc: "Elementos de acción (ej. botón) que se ubicarán en la parte derecha del encabezado"

  def card(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "relative bg-card rounded-md shadow-sm shadow-neutral-200",
        "#{if @loading, do: "overflow-clip"}",
        @root_class
      ]}
    >
      <div class={[
        "absolute bg-white/90 w-full h-full transition-opacity",
        "#{if @loading, do: "z-10 opacity-100", else: "-z-50 opacity-0"}"
      ]}>
        <.spinner
          class="absolute left-[50%] top-[50%] translate-x-[-50%] translate-y-[-50%]"
          message={@loading_message}
        />
      </div>
      <div class={["p-6", @class]} {@rest}>
        <.container_header
          :if={@title || @subtitle || length(@header_action) > 0}
          title={@title}
          subtitle={@subtitle}
          class={"#{if @filled_card_header, do: "!p-4 !mb-6 !-mt-6 !-mx-6 !border-none " <> @header_color <> " rounded-t-lg h-[4.5rem]", else: "h-14"}"}
          header_font_size={@header_font_size}
        >
          <:actions>
            <%= render_slot(@header_action) %>
          </:actions>
        </.container_header>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :show, :boolean, default: false
  attr :persist, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <%!-- <.focus_wrap></.focus_wrap> --%>
            <div
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={!@persist && JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden transition"
            >
              <.card
                id={"#{@id}-content"}
                title={@title}
                subtitle={@subtitle}
                root_class="!shadow-lg !rounded-2xl shadow-zinc-700/10 ring-zinc-700/10 ring-1"
                header_font_size="xl"
              >
                <:header_action>
                  <div
                    class="flex items-center justify-end space-x-3"
                    phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  >
                    <.icon
                      name="hero-x-mark-solid"
                      class="cursor-pointer opacity-40 hover:opacity-60"
                      size="36px"
                    />
                  </div>
                </:header_action>

                <div class="text-lg font-medium text-gray-600">
                  <%= render_slot(@inner_block) %>
                </div>
              </.card>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil

  attr :kind, :atom,
    values: [:default, :info, :warn, :error],
    doc: "used for styling and flash lookup"

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed bottom-4 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :default && "bg-sky-50 text-sky-800 ring-sky-500 fill-sky-200",
        @kind == :warn && "bg-amber-50 text-amber-800 ring-amber-500 fill-amber-200",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :default} name="hero-information-circle-mini" />
        <.icon :if={@kind == :warn} name="hero-information-circle-mini" />
        <.icon :if={@kind == :info} name="hero-information-circle-mini" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:default} title="Aviso" flash={@flash} />
      <.flash kind={:warn} title="Atención!" flash={@flash} />
      <.flash kind={:info} title="Éxito!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title="Error de red"
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        Intentando reconectar <.icon name="hero-arrow-path" class="ml-1 animate-spin" />
      </.flash>

      <%!-- phx-connected={hide("#server-error")} --%>
      <.flash
        id="server-error"
        kind={:error}
        title="Algo salió mal"
        phx-disconnected={show(".phx-server-error #server-error")}
        hidden
      >
        Ocurrió un error en el servidor
        <%!-- <.icon name="hero-arrow-path" class="ml-1 animate-spin" /> --%>
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  # rounded-md space-y-8 bg-white p-8 shadow-sm shadow-slate-300
  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <%= render_slot(@inner_block, f) %>
      <div :for={action <- @actions} class="mt-2 flex gap-3 flex-wrap">
        <%= render_slot(action, f) %>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)
  attr :color, :string, values: ["primary", "secondary", "danger", "default"], default: "primary"

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg py-2 px-4 transition-all text-sm font-semibold leading-6 btn",
        "#{if @color == "primary", do: "btn-primary"}",
        "#{if @color == "secondary", do: "btn-secondary"}",
        "#{if @color == "danger", do: "btn-danger"}",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :floating_label, :string, default: nil
  attr :value, :any
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil
  attr :hide_errors, :boolean, default: false
  attr :error_blank_placeholder, :boolean, default: false

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week money)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name} class={@class}>
      <label class="flex items-center gap-2 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name} class={@class}>
      <label class="flex items-center gap-2 text-sm leading-6 text-zinc-600">
        <input
          type="radio"
          id={@id}
          name={@name}
          value={@value}
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["relative", @class]}>
      <.label for={@id}><%= @label %></.label>
      <label
        :if={@floating_label}
        for={@id}
        class="absolute -top-3 left-2 rounded text-slate-700 bg-card px-1 text-xs"
      >
        <%= @floating_label %>
      </label>
      <select
        id={@id}
        name={@name}
        class={[
          "#{if @label, do: "mt-2"}",
          "appearance-none text-sm leading-6 px-3 py-2 pr-8 block w-full rounded-md border border-gray-300 bg-white",
          "shadow-sm focus:border-zinc-400 focus:ring-0"
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="" selected disabled><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["relative", @class]}>
      <.label :if={@label} for={@id}><%= @label %></.label>
      <label
        :if={@floating_label}
        for={@id}
        class="absolute -top-3 left-2 rounded text-slate-700 bg-card px-1 text-xs"
      >
        <%= @floating_label %>
      </label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "#{if @label, do: "mt-2"}",
          "block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "money"} = assigns) do
    if assigns[:id] == nil or assigns[:id] == "" do
      throw "Input money: El campo 'id' es obligatorio"
    end

    if String.match?(assigns[:id], ~r/^\d/) do
      throw "Input money: El campo 'id' no debe comenzar con un número"
    end

    ~H"""
    <div>
      <.input
        phx-hook="InputMoney"
        type="text"
        id={@id}
        name={@name}
        value={@value}
        class={@class}
        input_class={@input_class}
        label={@label}
        floating_label={@floating_label}
        errors={@errors}
        hide_errors={@hide_errors}
        error_blank_placeholder={@error_blank_placeholder}
        {@rest}
      />
      <input type="hidden" id={"#{@id}-hidden-value"} name={@name} value={@value} />
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["relative", @class]}>
      <.label :if={@label} for={@id}><%= @label %></.label>
      <label
        :if={@floating_label}
        for={@id}
        class="absolute -top-3 left-2 rounded text-slate-700 bg-card px-1 text-xs"
      >
        <%= @floating_label %>
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "#{if @label, do: ""}",
          "block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400",
          @input_class
        ]}
        {@rest}
      />

      <%= unless @hide_errors do %>
        <div class={"#{if @floating_label && @error_blank_placeholder, do: "mb-2"}"}>
          <.error :for={msg <- @errors}>
            <%= msg %>
          </.error>

          <div :if={@error_blank_placeholder && length(@errors) == 0} class="mt-3 text-sm leading-6">
            &nbsp;
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  attr :show_icon, :boolean, default: true
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class={["mt-3 flex gap-1 text-sm leading-6 text-rose-600 phx-no-feedback:hidden", @class]}>
      <.icon :if={@show_icon} name="hero-exclamation-circle-mini" class="flex-none align-text-bottom" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc """
  Renders a small header container with title and subtitle and actions, as to be included in other containers
  such as modals and cards to maintain a consistent style on components with headers.

  Attributes:

    * `:title` - The title on the leftmost side of the header
    * `:subtitle` - A smaller text under the title
    * `:size` - The size of the title and subtitle

  Slots:

    * `:actions` - Actions to be displayed to the rightmost side of the title

  ## Examples

  <.card>
    <.container_header title="TARJETAS">
      <:actions>
        <.button> GUARDAR </.button>
        <.button> ACTUALIZAR </.button>
      </:actions>
    </.container_header>

    // card_content
  </.card>
  """
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :header_font_size, :string, values: ["base", "lg", "xl"], default: "base"
  attr :class, :string, default: nil

  slot :actions, default: nil

  def container_header(assigns) do
    header_font_size =
      case assigns.header_font_size do
        "base" ->
          %{title: "text-lg", subtitle: "text-sm"}

        "lg" ->
          %{title: "text-xl", subtitle: "text-base"}

        "xl" ->
          %{title: "text-2xl", subtitle: "text-lg"}
      end

    assigns = assign(assigns, header_font_size: header_font_size)

    ~H"""
    <div class={[
      "flex items-center",
      "pb-4 mb-4 -mt-2 border-b border-gray-200",
      @class
    ]}>
      <div class="flex flex-1 flex-col font-medium">
        <div class={["text-slate-700", "#{@header_font_size[:title]}"]}>
          <%= @title %>
        </div>
        <div class={["text-slate-500", "#{@header_font_size[:subtitle]}"]}>
          <%= @subtitle %>
        </div>
      </div>
      <div class="flex items-center justify-end space-x-3">
        <%= render_slot(@actions) %>
      </div>
    </div>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"
  attr :class, :string, default: nil
  attr :sticky_header, :boolean, default: false
  attr :sorting_component, :any, default: nil
  attr :sorting_data, :map, default: %{}, doc: "%{sort_by: nil, sort_dir: nil}"
  attr :filter_component, :any, default: nil
  attr :priority_component, :any, default: nil
  attr :cadena, :boolean, default: false
  attr :has_total, :boolean, default: false
  attr :total_row, :any, default: nil

  attr :filters_data, :map,
    default: %{},
    doc: "Valores de los filtros para cada columna",
    required: false

  attr :columns_visibility, :map,
    default: %{},
    required: false,
    doc: "Visibilidad de las columnas"

  attr :priority_columns, :map,
    default: %{},
    required: false,
    doc: "Prioridad de las columnas"

  attr :column_order, :list, default: [], doc: "Orden de las columnas", required: false
  attr :draggable_columns, :boolean, default: false, doc: "option draggable", required: false

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :sort_key, :any, doc: "the sorting key"
    attr :filter_key, :any, doc: "the filtering key", required: false

    attr :type_priority, :any,
      doc:
        "este atributo esteblece el tipo de prioridad que manejara cada columna PR, PI o ambas",
      required: false

    attr :show_priority, :boolean, doc: "Muestra o no el componente de prioridad", required: false

    attr :fixed_filters, :any, doc: "Filtros fijos", required: false

    attr :search_enabled, :boolean, doc: "search by value", required: false
    attr :range_enabled, :boolean, doc: "search by range", required: false
    attr :type_input, :string, required: false
    attr :label, :string
    attr :sticky, :boolean, doc: "Utilizado para fijar la columna 'Acciones' como primera columna"

    attr :drag_hover, :boolean,
      doc:
        "Muestra o no el estilo draggable (hover), solo tiene efecto si @draggable_columns es true"
  end

  slot :action, doc: "the slot for showing user actions in the last table column"
  slot :header
  slot :pagination

  def table(assigns) do
    column_order =
      cond do
        # Asignación de column_order default
        length(assigns.column_order) > 0 ->
          assigns.column_order

        # Si no existe column_order, establecerlo con los labels de las columnas,
        # para que se muestren los datos en tablas donde no se tengan filtros
        length(assigns.column_order) == 0 and length(assigns.rows) > 0 ->
          Enum.map(assigns.col, fn col -> Map.get(col, :label, "NO_TEXT") end) |> Enum.uniq()

        true ->
          []
      end

    assigns =
      assign(assigns,
        column_order: column_order
      )

    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="table-root">
      <div :if={length(@header) > 0} class="pb-6">
        <%= render_slot(@header) %>
      </div>

      <%!-- Contenedor temporal para mover el nodo table al visualizar la caja de filtros si se tienen los headers
      como persistentes (sticky), de modo que no se "corten" si la tabla tiene overflow. --%>
      <div :if={@sticky_header} class={["table-temp-container pb-px px-4 !overflow-hidden", @class]} />

      <div
        class={["pb-px px-4 table-container", @class]}
        data-id={@id}
        id={"#{@id}-table-container"}
        phx-hook="TableContainer"
        data-sticky-header={"#{@sticky_header}"}
      >
        <table class="w-[40rem] sm:w-full">
          <thead class="text-sm text-left leading-6 text-zinc-500">
            <tr {if @draggable_columns, do: ["phx-hook": "DraggableColumns", id: "draggable-columns-#{@id}"], else: []}>
              <%= for col_label <- @column_order do %>
                <th
                  :for={{col, _i} <- Enum.with_index(@col)}
                  :if={Map.get(@columns_visibility, col_label, true) and col[:label] == col_label}
                  class={[
                    "py-4 pl-1 pr-4 font-normal rounded-md transition-colors duration-100 ease-in-out",
                    "#{if @draggable_columns and Map.get(col, :drag_hover, true), do: "cursor-pointer hover:bg-gray-200/75", else: ""}",
                    "#{if @sticky_header, do: "sticky top-0 z-[4]", else: ""}"
                  ]}
                >
                  <div class="flex items-center space-x-2">
                    <span
                      :if={@sticky_header}
                      class="-z-10 absolute -inset-y-px right-0 -left-4 bg-white border-b border-zinc-200"
                    />

                    <%= if @sorting_component && col[:sort_key] do %>
                      <.live_component
                        module={@sorting_component}
                        id={
                          if is_atom(col[:sort_key]),
                            do: Atom.to_string(col[:sort_key]),
                            else: col[:sort_key]
                        }
                        cadena={@cadena}
                        key={col[:sort_key]}
                        label={col[:label]}
                        sorting={@sorting_data}
                      />
                    <% else %>
                      <%= col[:label] %>
                    <% end %>

                    <%= if @filter_component && col[:filter_key] do %>
                      <%!-- <%= Debug.print(@filters_data[col[:filter_key]], label: "FILTER DATA", kernel: true) %> --%>
                      <.live_component
                        module={@filter_component}
                        id={"filter-#{col[:filter_key]}"}
                        key={col[:filter_key]}
                        column={col[:filter_key]}
                        column_data={@filters_data[col[:filter_key]]}
                        search_enabled={Map.get(col, :search_enabled, false)}
                        range_enabled={Map.get(col, :range_enabled, false)}
                        type_input={Map.get(col, :type_input, "text")}
                        fixed_filters={Map.get(col, :fixed_filters, [])}
                      />
                    <% end %>

                    <%= if @priority_component && col[:filter_key] do %>
                      <.live_component
                        module={@priority_component}
                        id={"priority-#{col[:filter_key]}"}
                        column={col[:filter_key]}
                        priority_columns={@priority_columns}
                        cadena={@cadena}
                        type_priority={Map.get(col, :type_priority, [])}
                        show_priority={Map.get(col, :show_priority, true)}
                      />
                    <% end %>
                  </div>
                </th>
              <% end %>
              <th :if={@action != []} class="relative p-0 pb-4">
                <span class="sr-only">
                  <%= gettext("Actions") %>
                </span>
              </th>
            </tr>
          </thead>

          <tbody
            id={@id}
            phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
            class="relative whitespace-nowrap divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
          >
            <tr
              :for={{row, _index} <- Enum.with_index(@rows)}
              id={@row_id && @row_id.(row)}
              class="group"
            >
              <%= for col_label <- @column_order do %>
                <td
                  :for={{col, _i} <- Enum.with_index(@col)}
                  :if={Map.get(@columns_visibility, col_label, true) and col[:label] == col_label}
                  phx-click={@row_click && @row_click.(row)}
                  class={[
                    "relative p-0",
                    @row_click && "hover:cursor-pointer",
                    col[:sticky] && "sticky left-0 z-[1]",
                  ]}
                  data-sticky-column={"#{col[:sticky]}"}
                >
                  <div class={["block py-4 pr-6"]}>
                    <span class="absolute -inset-y-px right-0 -left-4 group-odd:bg-white group-even:bg-primary-subtle-light group-hover:bg-zinc-50 sm:rounded-l-xl" />
                    <span class={["relative"]}>
                      <%= render_slot(col, @row_item.(row)) %>
                    </span>
                  </div>
                </td>
              <% end %>

              <td :if={@action != []} class="relative w-14 p-0">
                <div class="relative whitespace-nowrap py-4 text-right text-sm">
                  <span class="absolute -inset-y-px -right-4 left-0 group-odd:bg-white group-even:bg-primary-subtle-light group-hover:bg-zinc-50 sm:rounded-r-xl" />
                  <span
                    :for={action <- @action}
                    class="relative ml-4 leading-6 text-zinc-900 hover:text-zinc-700"
                  >
                    <%= render_slot(action, @row_item.(row)) %>
                  </span>
                </div>
              </td>
            </tr>

            <tr :if={length(@rows) <= 0}>
              <td :for={_ <- @column_order} class="py-4 text-center text-zinc-400">
                Sin datos
              </td>
            </tr>
          </tbody>

          <tfoot :if={@has_total and length(@rows) > 0} class="sticky bottom-0">
            <tr>
              <%= for col_label <- @column_order do %>
                <td
                  :for={{col, _i} <- Enum.with_index(@col)}
                  :if={Map.get(@columns_visibility, col_label, true) and col[:label] == col_label}
                  class="relative p-0 font-bold"
                >
                  <div class="block py-1 pr-6">
                    <span class="absolute -inset-y-px right-0 -left-4 bg-neutral-50 sm:rounded-l-[0.250rem] border-t border-gray-200" />
                    <span class={["relative"]}>
                      <%= render_slot(col, @total_row) %>
                    </span>
                  </div>
                </td>
              <% end %>
            </tr>
          </tfoot>
        </table>

        <div
          :if={length(@rows) <= 0 && @column_order == []}
          class="flex mx-auto py-4 justify-center m-auto text-lg text-slate-400"
        >
          Sin datos para mostrar
        </div>
      </div>

      <div :if={length(@pagination) > 0 and length(@rows) > 0}>
        <%= render_slot(@pagination) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  attr :class, :string, default: nil
  attr :row_class, :string, default: nil

  slot :item, required: true do
    attr :title, :string, required: true
    attr :errors, :list
    attr :item_class, :string
  end

  def list(assigns) do
    ~H"""
    <div>
      <dl class={["divide-y divide-zinc-100", @class]}>
        <div :for={item <- @item} class={["flex gap-4 py-4 text-sm leading-6 sm:gap-8", @row_class]}>
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700">
            <%!-- flex flex-wrap --%>
            <span class="leading-4">
              <span class={item[:item_class]}>
                <%= render_slot(item) %>
              </span>

              <span :if={item[:errors]} class="text-rose-600 flex items-center gap-1">
                <%!-- <.icon name="hero-exclamation-circle-mini" /> --%>
                ! <%= Enum.join(item.errors, ", ") %>
              </span>
            </span>
          </dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil
  attr :size, :string, default: "20px"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} style={"width: #{@size}; height: #{@size};"} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(LynxwebWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LynxwebWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
