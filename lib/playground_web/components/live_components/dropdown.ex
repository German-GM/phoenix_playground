defmodule LynxwebWeb.LiveComponents.Dropdown do
  use LynxwebWeb, :custom_live_component

  @doc """
  Returns a button triggered dropdown with aria keyboard and focus support.

  Attributes:

    * `:id` - The id to uniquely identify this dropdown
    * `:class` - Optional additional classes to apply
    * `:link_click_data` - Optional, it's the global data to pass to all links when using the individual "on_click" event
    * `:phx_target` - Optional, use of @myself is only required if handling events in a live_component
    * `:position` - Optional, horizontal position of the dropdown
    * `:disabled` - Optional, disables the dropdown behaviour and changes the cursor to default

  Slots:

    * `:img` - The optional img to show beside the button title
    * `:title` - The button title
    * `:subtitle` - The button subtitle
    * `:icon` - The button icon
    * `:link` - The dropdown menu links, can be used to navigate, call a method or call a "on_click" event

  ## Examples

      <.dropdown id={@id}>
        <:img src={@current_user.avatar_url}/>
        <:title><%= @current_user.name %></:title>
        <:subtitle><%= @current_user.username %></:subtitle>
        <:icon><.icon /></:icon>

        <:link navigate={profile_path(@current_user)}>View Profile</:link>
        <:link navigate={~p"/profile/settings"}>Settings</:link>
      </.dropdown>
  """
  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :link_click_data, :any, default: nil
  attr :phx_target, :any, default: nil
  attr :position, :string, values: ["bottom-left", "bottom-right"], default: "bottom-right"
  attr :disabled, :boolean, default: false

  slot :img do
    attr :src, :string
  end

  slot :title
  slot :subtitle
  slot :icon

  slot :link do
    attr :navigate, :string
    attr :href, :string
    attr :method, :any
    attr :on_click, :string
  end

  def dropdown(assigns) do
    ~H"""
    <.live_component module={__MODULE__} {assigns_to_attributes(assigns)} />
    """
  end

  def mount(socket) do
    socket = socket
    |> assign(:show_dropdown, false)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "relative inline-block text-left",
      @class
    ]}>
      <button
        id={@id}
        phx-hook="FixedDropdown"
        phx-click={if @disabled, do: "", else: "toggle_dropdown"}
        phx-target={@myself}
        data-dropdown-state={"#{@show_dropdown}"}
        data-position={"#{@position}"}
        type="button"
        class={[
          "dropdown-btn hover:bg-gray-100 flex items-center p-2 rounded-full",
          "text-gray-400 hover:text-gray-600 transition-colors duration-200 ease-out",
          @disabled && "cursor-default opacity-25"
        ]}
        data-active-class="bg-gray-100"
        aria-haspopup="true"
      >
        <span class="flex w-full justify-between items-center">
          <span class="flex min-w-0 items-center justify-between space-x-3">
            <img
              :for={img <- @img}
              class="w-10 h-10 rounded-full flex-shrink-0"
              alt=""
              {assigns_to_attributes(img)}
            />
            <span
              :if={length(@title) > 0 || length(@subtitle) > 0 || length(@icon) > 0}
              class="flex-1 flex flex-col min-w-0"
            >
              <span class="text-neutral-800 text-sm font-medium truncate">
                <%= render_slot(@title) %>
              </span>
              <span class="text-gray-500 text-sm truncate">
                <%= render_slot(@subtitle) %>
              </span>
              <span class="text-gray-400 hover:text-gray-600">
                <%= render_slot(@icon) %>
              </span>
            </span>
          </span>

          <.icon
            :if={length(@title) > 0 || length(@subtitle) > 0}
            class="ml-1 text-gray-700"
            name="hero-chevron-down"
            size="16px"
          />
        </span>
      </button>

      <div
        id={"#{@id}-dropdown"}
        phx-click-away="toggle_dropdown"
        phx-target={@myself}
        :if={@show_dropdown}
        class={[
          "fixed z-50 mt-2 w-56 divide-y divide-gray-100",
          "rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        ]}
        role="menu"
        aria-labelledby={@id}
      >
        <div :for={link <- @link} class="py-1" role="none">
          <.link
            tabindex="-1"
            role="menuitem"
            class="text-gray-700 hover:bg-primary-subtle group flex items-center px-4 py-2 text-sm"
            phx-click={link[:on_click] && JS.push(link[:on_click], value: %{data: @link_click_data}) |> JS.push("toggle_dropdown", target: @myself)}
            phx-target={@phx_target}
            {assigns_to_attributes(link)}
          >
            <%= render_slot(link) %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("toggle_dropdown", _map, socket) do
    socket = socket
    |> update(:show_dropdown, fn show_dropdown ->
      !show_dropdown
    end)

    {:noreply, socket}
  end
end
