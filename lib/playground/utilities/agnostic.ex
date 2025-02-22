defmodule Playground.Utilities.Agnostic do
  @moduledoc """
  Módulo con funciones de ayuda genéricas.
  """

  @doc """
  Intenta obtener un valor anidado de un mapa:
  - Si lo encuentra lo regresara tal cual
  - Si NO lo encuentra regresara "nil" o un valor default si se especificó

  Agnostic.tryget(map, [:root_prop, :deep_prop, 1, :deeper_prop2], "no encontrado")
    - Salida: "deeper_prop2" (deep_prop->array, get_elem->1, map_prop->deeper_prop2)

  Agnostic.tryget(map, [:root_prop, :deep_prop, 99999], "no encontrado")
    - Salida: "no encontrado" (deep_prop->array, get_elem->99999)
  """
  def tryget(map, keys, default \\ nil)
  def tryget(_map, [], default), do: default
  def tryget(map, [key | []], default)
    when is_integer(key) and is_list(map) do
      case Enum.at(map, key) do
        nil -> default
        value -> value
      end
  end
  def tryget(map, [key | []], default)
    when is_map(map) do
      case Map.get(map, key) do
        nil -> default
        value -> value
      end
  end
  def tryget(map, [key | rest], default)
    when is_integer(key) and is_list(map) do
      case Enum.at(map, key) do
        nil -> default
        value when is_list(value) -> tryget_list(value, rest, default)
        value when is_map(value) -> tryget(value, rest, default)
        _ -> default
      end
  end
  def tryget(map, [key | rest], default)
    when is_map(map) do
      case Map.get(map, key) do
        nil -> default
        value when is_list(value) -> tryget_list(value, rest, default)
        value when is_map(value) -> tryget(value, rest, default)
        _ -> default
      end
  end
  def tryget(_map, _keys, default), do: default

  @doc """
  Compara dos mapas de forma recursiva.
  - map1: %{}, el primer mapa con el que inicia la funcion
  - map2: %{}, el segundo mapa a comparar contra el primer mapa
  - path: [], rastrea la ubicación actual dentro de la estructura de datos durante la comparación, lo que facilita la identificación de las diferencias.
  - keys_to_exclude: [], cuando se encuentre una de estas claves en la estructura de datos, la comparación no se realizará para ese campo en particular.
  """
  def deep_compare(map1, map2, path, keys_to_exclude) do
    map1
    |> Enum.map(fn
      {key, value} when is_map(value) ->
        value2 = Map.get(map2, key)

        if is_map(value2),
          do: deep_compare(value, value2, [key | path], keys_to_exclude),
          else: {value == value2, [key | path]}

      {key, value} when is_list(value) ->
        value2 = Map.get(map2, key)

        if is_list(value2) do
          if Enum.all?(value, &is_map/1) and Enum.all?(value2, &is_map/1) do
            value
            |> Enum.sort_by(&Map.take(&1, Map.keys(&1) -- keys_to_exclude))
            |> Enum.zip(value2 |> Enum.sort_by(&Map.take(&1, Map.keys(&1) -- keys_to_exclude)))
            |> Enum.map(fn {v1, v2} -> deep_compare(v1, v2, [key | path], keys_to_exclude) end)
          else
            {value == value2, [key | path]}
          end
        else
          {value == value2, [key | path]}
        end

      {key, value} ->
        if key in keys_to_exclude,
          do: {true, [key | path]},
          else: {value == Map.get(map2, key), [key | path]}
    end)
    |> Enum.filter(fn
      {equal, _path} -> !equal
      [[]] -> false
      [[], []] -> false
      _ -> true
    end)
  end

  @doc """
  Actualiza un mapa en una lista de mapas.
  """
  def update_map_in_list(list, prop_in_map, value_to_match, updates) do
    index = Enum.find_index(list, &("#{&1[prop_in_map]}" == "#{value_to_match}"))
    if index != nil do
      List.update_at(list, index, fn(element) -> element |> Map.merge(updates) end)
    else
      list
    end
  end

  @doc """
  Agrega o actualiza un valor a un mapa.
  Si la llave no existe en la ruta final especificada, se crea.
  Si la llave ya existe en la ruta final especificada, se actualiza.
  Si se pasa una lista vacía de llaves, se devuelve el mapa originañ.

  # Ejemplo:

  mapa = %{}
  Playground.Utilities.Agnostic.update_map_deep(mapa, [:message], "error")
  %{message: "error"}

  mapa = %{message: "error"}
  Playground.Utilities.Agnostic.update_map_deep(mapa, [], "datos")
  %{message: "error"} # Sin cambios al pasarse una lista vacía de llaves

  mapa = %{message: "error"}
  Playground.Utilities.Agnostic.update_map_deep(mapa, [:code], "500")
  %{message: "error", code: "500"}

  mapa = %{message: "error", code: "500"}
  Playground.Utilities.Agnostic.update_map_deep(mapa, [:status, :tarjeta], "21")
  %{code: "500", message: "error", status: %{tarjeta: "21"}}

  mapa = %{code: "500", message: "error", status: %{tarjeta: "21"}}
  Playground.Utilities.Agnostic.update_map_deep(mapa, [:code, :additional], "LP99")
  (BadMapError) expected a map, got: "500" # La llave existente :code no es un mapa,
  por tanto no se puede agregar/actualizar una llave anidada :additional con valor "LP99"
  """
  def update_map_deep(map, [], _value), do: map
  def update_map_deep(_map, _keys, _value, recursion \\ false)
  def update_map_deep(_map, [], value, true), do: value
  def update_map_deep(map, [key | rest], value, _recursion) do
    submap = Map.get(map, key, %{})
    Map.put(map, key, update_map_deep(submap, rest, value, true))
  end

  @doc """
  Convierte las llaves tipo atomo de un struct o mapa a llaves tipo string de manera recursiva, sin importar
  el nivel de anidación que se tenga. El valor de entrada puede ser un struct, mapa o lista.
  - Lista: se itera y se llama a si misma para cada elemento
  - Struct: se convierte a un mapa normal y se llama a si misma
  - Mapa: se itera cada par llave-valor, se convierte cada llave tipo atomo a llave tipo string, y se llama a si misma para el valor
  - Otros: se devuelve el tipo de dato intacto

  # Ejemplo:

  Agnostic.map_atom_keys_to_string_keys(%RootStruct{a: %{b: 1}, c: [1, 2, %InnerStruct{d: false}], "e" => true})
    - Salida: %{"a" => %{"b" => 1}, "c" => [1, 2, %{"d" => false}], "e" => true}
  """
  def map_atom_keys_to_string_keys(map) when is_map(map) and not is_struct(map) do
    Enum.map(map, fn {llave, valor} ->
      if is_atom(llave) do
        {Atom.to_string(llave), map_atom_keys_to_string_keys(valor)}
      else
        {llave, map_atom_keys_to_string_keys(valor)}
      end
    end)
    |> Map.new()
  end

  # Convertir un struct a un mapa normal
  def map_atom_keys_to_string_keys(struct) when is_struct(struct) do
    struct |> Map.from_struct() |> map_atom_keys_to_string_keys()
  end

  # Convertir una lista de mapas o structs
  def map_atom_keys_to_string_keys(list) when is_list(list) do
    Enum.map(list, fn item ->
      map_atom_keys_to_string_keys(item)
    end)
  end

  # Caso base para cuando el valor no es un mapa o struct
  def map_atom_keys_to_string_keys(valor) do
    valor
  end

  def mask_string(str, start_position, mask_length, replaced_char \\ "*")

  def mask_string(str, start_position, mask_length, replaced_char)
      when is_binary(str) and is_binary(replaced_char) do
    start_pos = min(start_position, String.length(str))
    mask_len = min(mask_length, String.length(str) - start_pos)

    unmasked_part_before = String.slice(str, 0, start_pos)
    unmasked_part_after = String.slice(str, start_pos + mask_len, String.length(str))

    masked_part = String.duplicate(replaced_char, mask_len)
    masked_string = "#{unmasked_part_before}#{masked_part}#{unmasked_part_after}"

    masked_string
  end

  def mask_string(any, _, _, _), do: any

  @doc """
  Separa un string dependiendo del substring contenido y devuelve el resultado en 3 partes:
  - El inicio de la cadena antes del substring
  - El substring
  - El resto de la cadena

  # Ejemplo:

  Agnostic.split_string_by_substring("0191a47d-c12e-47cb-acda-2d739f7dd608", "cda-2d739f7dd")
    - Salida: {:ok, {"0191a47d-c12e-47cb-a", "cda-2d739f7dd", "608"}}
  """
  def split_string_by_substring(string, substring) do
    case :binary.match(string, substring) do
      :nomatch ->
        {:error, "Substring not found"}

      {start_pos, length} ->
        prefix = String.slice(string, 0, start_pos)
        middle = String.slice(string, start_pos, length)
        suffix = String.slice(string, (start_pos + length)..-1//1)
        {:ok, {prefix, middle, suffix}}
    end
  end

  defp tryget_list([], _keys, default), do: default
  defp tryget_list([head | _tail], [], _default), do: head
  defp tryget_list(list, keys, default) do
    # [_head | tail] = list
    case tryget(list, keys, nil) do
      nil -> default # tryget_list(tail, keys, default)
      value -> value
    end
  end
end
