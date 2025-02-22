defmodule Playground.Utilities.Agnostic.ApiHelpers do
  @moduledoc """
  Funciones de ayuda genericas para manejar APIs
  """
  alias Playground.Utilities.Agnostic
  alias Agnostic.SchemaHelpers
  alias Playground.ApiManager.CardServices.DockOne.BitacoraTdClient
  alias Playground.ApiManager.LynxBrain.BitacoraLynxClient

  # {:ok, %Req.Response{status: status, body: body}}
  @spec handle_json_response(
          {:error, any()} | {:ok, any()} | {:error, any(), any()},
          Plug.Conn.t()
        ) :: Plug.Conn.t()
  def handle_json_response({:ok, %{status: status, body: body}}, conn) do
    conn
    |> Plug.Conn.put_status(status)
    |> Phoenix.Controller.json(body)
  end

  # {:error, %Req.Response{status: status, body: body}}
  def handle_json_response({:error, %{status: status, body: body}}, conn) do
    conn
    |> Plug.Conn.put_status(status)
    |> Phoenix.Controller.json(body)
  end

  def handle_json_response({:ok, body}, conn) do
    conn
    |> Plug.Conn.put_status(:ok)
    |> Phoenix.Controller.json(body)
  end

  def handle_json_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    errors = SchemaHelpers.format_changeset_errors(changeset)

    conn
    |> Plug.Conn.put_status(400)
    |> Phoenix.Controller.json(%{error: errors})
  end

  def handle_json_response({:error, error}, conn) do
    conn
    |> Plug.Conn.put_status(:internal_server_error)
    |> Phoenix.Controller.json(%{error: error})
  end

  def handle_json_response({:error, _, error}, conn) do
    conn
    |> Plug.Conn.put_status(:internal_server_error)
    |> Phoenix.Controller.json(%{error: error})
  end

  def handle_transport_error(%Mint.TransportError{reason: reason}) do
    case reason do
      :nxdomain ->
        %{"error_red" => "No existe el dominio especificado del recurso."}

      :timeout ->
        %{"error_red" => "Se terminó el tiempo límite de respuesta de la petición."}

      :closed ->
        %{
          "error_red" =>
            "Se estableció una conexión al recurso solicitado, pero se cerró inesperadamente antes de que se pudiera completar."
        }

      _ ->
        reason
    end
  end

  def handle_transport_error(%Mint.HTTPError{reason: reason}) do
    case reason do
      :invalid_request_target ->
        %{"error_red" => "La ruta de la petición no es válida."}

      _ ->
        reason
    end
  end

  def return_response_by_status(response, status) do
    case status do
      status when status in [200, 201, 202, 204] ->
        {:ok, response}

      status when status in [400, 403, 422, 404, 500] ->
        response = Playground.Utilities.Agnostic.update_map_deep(response, [:body, "error", "context"], "ex")
        {:error, response}

      409 ->
        case Jason.decode(response.body) do
          {:ok, decoded_body} ->
            if Map.get(decoded_body, "Success", "") == "rsAuth" do
              {:ok, response}
            else
              {:error, response}
            end

          {:error, _} ->
            {:error, %{error: "Error decoding response body"}}
        end

      _ ->
        response = Playground.Utilities.Agnostic.update_map_deep(response, [:body, "error", "context"], "ex")
        {:error, response}
    end
  end

  def build_request(method, url, body \\ %{}) do
    %{
      method: method,
      url: url,
      body: body
    }
  end

  def build_request_soap(body_xml, url_ws) do
    %{
      method: :post,
      url: url_ws,
      body: body_xml
    }
  end

  @spec run_request_json(
          %{method: :post | :get | :put | :patch | :delete, url: String.t(), body: map()},
          list(),
          list()
        ) :: {:ok, Req.Response.t()} | {:error, Req.Response.t()}
  def run_request_json(request, headers, connect_options) do
    apply(Req, request[:method], [
      request[:url],
      [
        headers: headers,
        connect_options: connect_options,
        json: request[:body] || %{}
      ]
    ])
  end

  @spec run_request_body(
          %{method: :post | :get | :put | :patch | :delete, url: String.t(), body: map()},
          list(),
          list()
        ) :: {:ok, Req.Response.t()} | {:error, Req.Response.t()}
  def run_request_body(request, headers, connect_options) do
    apply(Req, request[:method], [
      request[:url],
      [
        headers: headers,
        connect_options: connect_options,
        body: request[:body] || %{}
      ]
    ])
  end

  def run_request_json(request, headers) do
    apply(Req, request[:method], [
      request[:url],
      [
        headers: headers,
        json: request[:body] || %{}
      ]
    ])
  end

  def run_request_body(request, headers) do
    apply(Req, request[:method], [
      request[:url],
      [
        headers: headers,
        body: request[:body] || %{}
      ]
    ])
  end

  def run_request_soap(request, soap_action \\ "") do
    apply(Req, request[:method], [
      request[:url],
      [
        headers: [
          {"Content-Type", "text/xml; charset=utf-8"},
          {"SOAPAction", soap_action}
        ],
        body: request[:body]
      ]
    ])
  end

  # ====================
  # HANDLERS REUSABLES
  # ====================
  def handle_response({:ok, response}, idtipos_procesos_td, request, log_params)
      when is_map(log_params) do
    response_data = %{
      status: response.status,
      headers: response.headers,
      body: response.body
    }

    log_ids_to_save = log_id_processes_to_save()

    if idtipos_procesos_td in log_ids_to_save do
      bitacora = Map.get(log_params, :bitacora, "debito")

      # Bitacoras
    end

    return_response_by_status(response, response.status)
  end

  def handle_response({:error, response}, _idtipos_procesos_td, _request, log_params)
      when is_map(log_params) do
    {:error, handle_transport_error(response)}
  end

  def get_generic_ui_error_as_state({:error, :database, errors}),
    do: [errors: errors]

  def get_generic_ui_error_as_state({:error, :not_found, errors}),
    do: [errors: errors]

  def get_generic_ui_error_as_state({:error, :unknown, errors}),
    do: [errors: errors]

  def get_generic_ui_error_as_state({:error, %Req.Response{status: status, body: body}}) do
    errors = %{
      "error_req_response" => "#{status} - #{Agnostic.tryget(body, ["error", "description"])}"
    }

    [errors: errors]
  end

  def get_generic_ui_error_as_state({:error, %DBConnection.ConnectionError{} = error}) do
    errors = %{
      "database_connection_error" => error.message
    }

    [errors: errors]
  end

  def get_generic_ui_error_as_state({:error, errors}),
    do: [errors: errors]

  def additional_log_id_processes_to_save() do
    System.get_env("ADDITIONAL_LOG_ID_PROCESSES_TO_SAVE", "")
    |> String.split(",", trim: true)
    |> Enum.map(&(String.trim(&1) |> String.to_integer()))
  end

  def default_log_id_processes_to_save() do
    [
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      10,
      12,
      14,
      15,
      18,
      20,
      21,
      27,
      28,
      31,
      34,
      37,
      40
    ]
  end

  # iex> Debug.show_log_id_processes_to_save()
  def log_id_processes_to_save() do
    # Lista default solo con los IDs de procesos necesarios a guardar en la bitácora
    default_log_ids_to_save = default_log_id_processes_to_save()

    # Lista de IDs específicos a incluir en el guardado de la bitácora, por si se requiere ver
    # algún log de uno o varios procesos no incluidos en la lista default
    additional_log_ids_to_save = additional_log_id_processes_to_save()

    # Se combinan las listas de IDs default y adicionales y se eliminan los IDs duplicados
    default_log_ids_to_save
    |> Enum.concat(additional_log_ids_to_save)
    |> Enum.uniq()
  end
end
