defmodule Playground.Utilities.CodeParser do
  @moduledoc false

  def gender(code) do
    case code do
      3 -> "Masculino"
      4 -> "Femenino"
      6 -> "Otro"
      _ -> "Error: Genero desconocido"
    end
  end

  def doc_type(code) do
    case code do
      84 -> "Lic. de conducir"
      85 -> "Pasaporte"
      89 -> "CURP"
      90 -> "INE"
      125 -> "Cédula"
      16_144 -> "RFC"
      _ -> "Error: Tipo documento desconocido"
    end
  end

  def card_status(status) do
    case status do
      "NORMAL" -> "NORMAL"
      "BLOCKED" -> "BLOQUEADA"
      "CANCELED" -> "CANCELADA"
      _ -> "Error: Estatus tarjeta desconocido"
    end
  end

  def card_type(type) when is_binary(type) do
    case type do
      "PHYSICAL" -> "FÍSICA"
      "VIRTUAL" -> "VIRTUAL"
      _ -> "Error: Tipo tarjeta desconocido"
    end
  end

  def card_type(type) when is_integer(type) do
    case type do
      1 -> "PHYSICAL"
      2 -> "VIRTUAL"
      _ -> "Error: Tipo tarjeta desconocido"
    end
  end

  def card_used(code) do
    case code do
      0 -> "Sin usar"
      1 -> "En uso"
      _ -> "Error: Estado de uso de tarjeta desconocido"
    end
  end

  def phone_type(code) do
    case code do
      55 -> "Residencial"
      56 -> "Móvil"
      58 -> "Comercial"
      _ -> "Error: Tipo teléfono desconocido"
    end
  end

  def proceso(code) do
    case code do
      1 -> "Consultar datos de un Socio para validarlos con Dock One"
      2 -> "Registro de los datos de un socio en Dock One"
      3 -> "Actualizar los datos de un socio en Dock One"
      4 -> "Crear cuenta"
      5 -> "Vincular cuenta Alias"
      6 -> "Actualizar Status Tarjeta"
      7 -> "Actualizar los datos de un socio en Entura"
      8 -> "Paso 1 Crear un lote de tarjetas"
      9 -> "Paso 2 Creando un nuevo layout"
      10 -> "Paso 3 Generando un archivo de embossing"
      11 -> "Paso 4 Descargando un archivo de embossing"
      12 -> "Crear una nueva tarjeta virtual"
      13 -> "Obtener lista de archivos de embossing"
      14 -> "Subir clave pública RSA de Lynx a DockOne"
      15 -> "Actualizar clave pública RSA de Lynx a DockOne"
      16 -> "Listar los datos sensibles de la tarjeta"
      17 -> "Consultar un CVV dinámico de una tarjeta específica"
      18 -> "Crear un CVV dinámico"
      19 -> "Consultar PIN por ID"
      20 -> "Solicitar clave pública RSA de DockOne"
      21 -> "Actualizar clave pública RSA de DockOne"
      22 -> "Consultar clave pública RSA"
      23 -> "Encontrar tarjeta por PAN"
      24 -> "Verificar el CVV de la tarjeta"
      25 -> "Verificar la fecha de vencimiento de la tarjeta"
      26 -> "Verificar el PIN de la tarjeta"
      27 -> "Actualizar el PIN de la tarjeta"
      28 -> "Iniciar transferencia"
      29 -> "Listar transferencias"
      30 -> "Buscar recibo transferencia"
      31 -> "Cancelar transferencia programada"
      32 -> "Listar alias"
      33 -> "Listar una tarjeta específica"
      34 -> "Eliminar un CVV dinámico de una tarjeta específica"
      35 -> "Obtener reporte de Morpheus"
      36 -> "Login en Lynx Brain"
      37 -> "Crear contrato de débito"
      38 -> "Obtener PDF de contrato de débito"
      39 -> "Obtener estatus actual de el socio"
      40 -> "Vincular tarjeta a socio en Entura"
      _ -> "Warning: Proceso desconocido"
    end
  end

  def entidad_no_procesable(code) do
    case code do
      "DCPAY-422001" ->
        "Una solicitud de transferencia igual ya está en proceso, por favor intente de nuevo en 30s."

      "DCPAY-422002" ->
        "Este emisor no está activo para realizar esta transacción"

      "DCPAY-422003" ->
        "Tipo de clave 'key_type' del deudor no reconocido. Por favor, siga el enum permitido."

      "DCPAY-422004" ->
        "Clave del acreedor (CREDITOR_ID) no encontrada. Por favor, revise esta información."

      "DCPAY-422005" ->
        "Tipo de clave 'key_type' del acreedor no reconocido. Por favor, siga el enum permitido."

      "DCPAY-422006" ->
        "El parámetro 'scheduling_date' debe ser una fecha futura. Máximo 3 meses adelante."

      "DCPAY-422007" ->
        "Tipo de operación 'operation_type' no encontrado en la configuración del emisor"

      _ ->
        "Error: Código desconocido"
    end
  end

  def type_report(code) do
    case code do
      1 -> "Reporte de Embozado"
      2 -> "Reporte de Tarjetas"
      3 -> "Reporte de Asignación de Tarjetas"
      4 -> "Reporte de Archivos de Embozado"
    end
  end

  @doc """
  Transforma el código de estado de la BD en un código de 2 letras.
  Requerido para vincular tarjetas y actualizar datos a socios en Entura.
  """
  def estado_cc_entura(code) do
    case code do
      "AGS"  -> "AS"
      "BC"   -> "BC"
      "BCS"  -> "BS"
      "CAMP" -> "CC"
      "CHIH" -> "CH"
      "COAH" -> "CL"
      "COL"  -> "CM"
      "CHIS" -> "CS"
      "CDMX" -> "DF"
      "DGO"  -> "DG"
      "GTO"  -> "GT"
      "GRO"  -> "GR"
      "HGO"  -> "HG"
      "JAL"  -> "JC"
      "MEX"  -> "MC"
      "MICH" -> "MN"
      "MOR"  -> "MS"
      "NAY"  -> "NT"
      "NL"   -> "NL"
      "OAX"  -> "OC"
      "PUE"  -> "PL"
      "QRO"  -> "QT"
      "QROO" -> "QR"
      "SLP"  -> "SP"
      "SIN"  -> "SL"
      "SON"  -> "SR"
      "TAB"  -> "TC"
      "TAMP" -> "TS"
      "TLAX" -> "TL"
      "VER"  -> "VZ"
      "YUC"  -> "YN"
      _      -> "NO" # No Asignado
    end
  end
end
