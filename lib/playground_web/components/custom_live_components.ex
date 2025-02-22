defmodule LynxwebWeb.CustomLiveComponents do
  @moduledoc """
  Este módulo se utiliza para autoimportación de los LiveComponents por medio del módulo LynxwebWeb
  expandiendo los imports en las funciones "live_view" y "live_component" (con "use LynxwebWeb.CustomLiveComponents").
  """

  @doc """
  Se iteran los LiveComponents para transformar sus nombres en imports, extrayendo solo la función
  relevante de cada módulo importado.

  ## Ejemplo de código generado

    import LynxwebWeb.LiveComponents.AutocompleteInput, only: [autocomplete_input: 1]
    import LynxwebWeb.LiveComponents.SplitButton, only: [split_button: 1]
    Etc...
  """
  defmacro __using__(_) do
    Enum.map([
      # Agregar aquí los live_components que se quieran autoimportar para utilizarse como tags HTML
      LynxwebWeb.LiveComponents.AutocompleteInput,
      LynxwebWeb.LiveComponents.SplitButton,
      LynxwebWeb.LiveComponents.Dropdown,
    ], fn module ->
      function_name = module
      |> Module.split()
      |> List.last()
      |> Macro.underscore()
      |> String.to_atom()

      quote do
        import unquote(module), only: unquote(Keyword.new([{function_name, 1}]))
      end
    end)
  end

end
