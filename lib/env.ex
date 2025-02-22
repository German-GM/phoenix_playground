defmodule Env do
  def to_boolean(str) when is_binary(str) do
    String.downcase(str) == "true"
  end

  def to_boolean(_), do: false

  # Devuelve true si el entorno es de desarrollo, versión expandida en modulo Debug
  def dev_env?(),
    do: Application.fetch_env!(:lynxweb, :env) == :dev

  # Devuelve true si la var. de entorno MODO_DEBUG existe y es igual a 1
  def debug_mode?(),
    do: System.get_env("MODO_DEBUG", "0") == "1"

  # Devuelve true si la var. de entorno MODO_PRUEBAS no existe, o bien, si existe y es igual a 1
  def test_mode?(),
    do: System.get_env("MODO_PRUEBAS", "1") == "1"

  def dock_one_service?(),
    do: System.get_env("DOCK_ONE", "0") == "1"

  def entura_service?(),
    do: System.get_env("ENTURA", "0") == "1"

  def get_card_service!() do
    cond do
      dock_one_service?() -> :dock_one
      entura_service?() -> :entura
      true -> raise "get_card_service! - No se ha definido un servicio de tarjetas"
    end
  end
end
