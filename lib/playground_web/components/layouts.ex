defmodule LynxwebWeb.Layouts do
  use LynxwebWeb, :html
  use LynxwebWeb, :live_component

  embed_templates "layouts/*"
end
