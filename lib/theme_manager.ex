defmodule ThemeManager do
  @moduledoc """
  Módulo para manejar los temas de la aplicación.

  Añadir un nuevo tema:
  1. Establecer el tema de color en "assets/css/themes.css"
  2. Poner el logo en "priv/static/images/<theme>_logo.svg". El formato siempre deberá ser un archivo de vector SVG.
  3. Agregar el tema en la lista "@available_themes" en este módulo.
  4. Probar los colores del nuevo tema y ajustarlos si es necesario.

  Test:
  iex> ThemeManager.set_theme("iturbide")
  iex> ThemeManager.set_theme("lynx")
  iex> ThemeManager.set_theme()
  iex> ThemeManager.set_theme("undefined")
  """

  alias PlaygroundWeb.Endpoint

  @fallback_theme "lynx"
  @available_themes [
    @fallback_theme,
    "iturbide",
    # etc...
  ]

  @doc """
  Obtiene el tema actual de la aplicación.
  Si no se ha inicializado un tema con set_theme(), se utilizará el tema establecido como fallback.
  """
  def get_theme(),
    do: Application.get_env(:lynxweb, :theme, @fallback_theme)

  @doc """
  Obtiene el logo del tema actual de la aplicación, en formato SVG.
  """
  def get_logo(),
    do: "#{get_theme()}_logo.svg"

  @doc """
  Establece el tema default de la aplicación (se le da prioridad a la variable de entorno APP_THEME).
  El tema establecido como fallback se aplicará de manera forzada en producción solo cuando se usa el modo de prueba
  ! Utilizado actualmente al momento de realizar un login exitoso.
  """
  def set_theme() do
    if not Env.dev_env?() and Env.test_mode?() do
      Application.put_env(:lynxweb, :theme, @fallback_theme)
    else
      app_theme = System.get_env("APP_THEME", @fallback_theme)
      apply_theme!(app_theme)
    end
  end

  @doc """
  Sobreescribe el tema de la aplicación.
  Solo se tomaran en cuenta temas válidos.
  """
  def set_theme(theme),
    do: apply_theme!(theme)

  defp apply_theme!(theme) do
    if theme in @available_themes do
      Endpoint.broadcast("theme:change", "theme_change_from_server", %{new_theme: theme})
      Application.put_env(:lynxweb, :theme, theme)
    else
      raise "Tema no aplicado: El nombre de tema \"#{theme}\" no es válido."
    end
  end
end
