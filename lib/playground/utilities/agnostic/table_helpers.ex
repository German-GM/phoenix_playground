defmodule Playground.Utilities.Agnostic.TableHelpers do
  alias PlaygroundWeb.LiveComponents.{
    PaginationForm
  }

  alias Playground.ApiManager.LynxServices.DatatableStructures.SaveViewTableClient

  defmacro inject_function(client_module, filter_utils_module) do
    quote do
      # Checar por funciones de módulo requeridas en client_module
      required_methods = [
        {:calculate_total, 3}
      ]

      case Code.ensure_compiled(unquote(client_module)) do
        {:module, mod} ->
          Enum.each(required_methods, fn {method, arity} ->
            if not function_exported?(mod, method, arity) do
              raise "#{mod}#{inspect(method)}/#{arity} is required by inject_function()."
            end
          end)
      end

      # Función para obtener datos de una columna
      defp get_column_data(socket, column) do
        cadena = Map.get(socket.assigns, :cadena, false)

        column =
          if cadena do
            column
          else
            case is_binary(column) do
              true ->
                try do
                  String.to_existing_atom(column)
                rescue
                  ArgumentError -> column
                end

              false ->
                column
            end
          end

        Map.get(socket.assigns.initial_filters, column, [])
      end

      def handle_info({:loading}, socket) do
        {:noreply, assign(socket, loading: true)}
      end

      def handle_info({:disable_loading}, socket) do
        {:noreply, assign(socket, loading: false)}
      end

      # Función para cambiar la prioridad de una columna PR/PI
      def handle_info({:change_priority, %{priority_columns: priority_columns}}, socket) do
        filters = socket.assigns.filter_querys
        params = merge_and_sanitize_params(socket)
        columns_visibility = socket.assigns.columns_visibility
        report_id = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        last_params = Map.get(socket.assigns, :last_params, %{})
        cadena = Map.get(socket.assigns, :cadena, false)
        current_user = socket.assigns.current_user
        id_sucursal = current_user.idsucursal

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          id_sucursal: id_sucursal,
          last_params: last_params
        }

        %{data: data, total_count: total_count} =
          if cadena do
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filters,
              priority_columns: priority_columns,
              log_params: log_params
            })
          else
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filters,
              priority_columns: priority_columns
            })
          end

        {socket, data} =
          if cadena do
            total_row =
              unquote(client_module).calculate_total(data, columns_with_total, columns_visibility)

            socket = assign(socket, total_row: total_row, last_params: params)
            {socket, data}
          else
            {socket, data}
          end

        socket =
          socket
          |> assign(filter_querys: filters)
          |> assign(data: data, loading: false)
          |> assign(priority_columns: priority_columns)
          |> assign_total_count(total_count)

        {:noreply, socket}
      end

      # Función para manejar la búsqueda de un filtro
      defp handle_filter_search(socket, column, value_search) do
        params = merge_and_sanitize_params(socket)
        id_report = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          id_report: id_report,
          id_usuario: id_usuario,
          columns_with_total: columns_with_total
        }

        {col_data, updated_fil} =
          if value_search == "" do
            init_column_data = get_column_data(socket, column)
            {init_column_data, socket.assigns.initial_filters}
          else
            result =
              unquote(client_module).filter_list_by_search(
                %{
                  column: column,
                  value_search: value_search
                },
                1,
                40,
                log_params
              )

            updated_filters =
              unquote(client_module).update_filters_by_search(result, column, socket)
              |> Enum.into(%{})

            column_data = unquote(client_module).get_unique_column_values(updated_filters, column)

            {column_data, updated_filters}
          end

        send_update(PlaygroundWeb.LiveComponents.FilterTables,
          id: "filter-#{column}",
          loading: false,
          column_data: col_data
        )

        {:noreply, assign(socket, filters: updated_fil)}
      end

      # Función para manejar la búsqueda por rango de un filtro
      defp handle_filter_search_by_range(socket, column, values_search_range) do
        params = merge_and_sanitize_params(socket)
        priority_columns = socket.assigns.priority_columns
        columns_visibility = socket.assigns.columns_visibility
        last_range = List.last(values_search_range)
        report_id = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        last_params = Map.get(socket.assigns, :last_params, %{})
        cadena = Map.get(socket.assigns, :cadena, false)
        current_user = socket.assigns.current_user
        id_sucursal = current_user.idsucursal

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          id_sucursal: id_sucursal,
          last_params: last_params
        }

        filters =
          socket.assigns
          |> Map.get(:filter_querys, %{})
          |> Map.update("Rango por #{column}", [last_range], fn valores_existentes ->
            valores_existentes ++ [last_range]
          end)

        %{data: data, total_count: total_count} =
          if cadena do
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filters,
              priority_columns: priority_columns,
              log_params: log_params
            })
          else
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filters,
              priority_columns: priority_columns
            })
          end

        {socket, data} =
          if cadena do
            total_row =
              unquote(client_module).calculate_total(data, columns_with_total, columns_visibility)

            socket = assign(socket, total_row: total_row, last_params: params)
            {socket, data}
          else
            {socket, data}
          end

        socket =
          socket
          |> assign(filter_querys: filters)
          |> assign(data: data)
          |> assign_total_count(total_count)

        {:noreply, socket}
      end

      # Función para manejar la eliminación de un rango de un filtro
      defp handle_delete_range_filters(socket, column, remove, values_search_range) do
        params = %{
          values: values_search_range,
          column: "Rango por #{column}",
          action: :remove,
          value_to_remove: remove
        }

        # Cuando es action remove, no es necesario mandar values se tiene que mandar []
        socket =
          socket
          |> search_request(
            params[:column],
            params[:values],
            params[:action],
            params[:value_to_remove]
          )

        {:noreply, socket}
      end

      # Función para manejar la visibilidad de las columnas
      defp handle_show_columns(socket, new_visibility, column) do
        priority_columns = socket.assigns.priority_columns
        reporte = Map.get(socket.assigns, :reporte, nil)
        filter_querys = socket.assigns.filter_querys
        params = merge_and_sanitize_params(socket)
        cadena = Map.get(socket.assigns, :cadena, false)
        # ENUM --------------------------------------------------------------
        report_id = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        last_params = Map.get(socket.assigns, :last_params, %{})
        id_sucursal = socket.assigns.current_user.idsucursal

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          id_sucursal: id_sucursal,
          last_params: last_params
        }

        # --------------------------------------------------------------------

        filters =
          socket.assigns
          |> Map.get(:filter_querys, %{})
          |> Map.delete(key_to_delete(column))
          |> Map.delete("Rango por #{String.downcase(column)}")

        send_update(PlaygroundWeb.LiveComponents.FilterQuerys,
          id: "filters_querys",
          filter_querys: filters,
          priority_columns: priority_columns
        )

        visible_columns =
          Enum.filter(socket.assigns.column_order, fn col ->
            Map.get(new_visibility, col, false)
          end)

        Debug.print(visible_columns, label: "VISIBLE COLUMNS 1")

        visible_columns =
          if Map.get(new_visibility, column, false) and not Enum.member?(visible_columns, column) do
            index = Enum.find_index(socket.assigns.column_order, fn col -> col == column end)

            if index do
              List.insert_at(visible_columns, index, column)
            else
              visible_columns ++ [column]
            end
          else
            visible_columns
          end

        {new_visibility, visible_columns} =
          remove_keys(new_visibility, visible_columns, reporte, column, params)

        {new_visibility, visible_columns} =
          add_missing_keys(new_visibility, visible_columns, reporte, column, params)

        Debug.print(visible_columns, label: "VISIBLE COLUMNS 2")
        Debug.print(new_visibility, label: "VISIBILITY")

        %{data: data, total_count: total_count} =
          if cadena do
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: new_visibility,
              params: params,
              filters_querys: filters,
              priority_columns: priority_columns,
              log_params: log_params
            })
          else
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: new_visibility,
              params: params,
              filters_querys: filters,
              priority_columns: priority_columns
            })
          end

        # if cadena do
        #   socket
        #   |> assign(column_order: visible_columns)
        #   |> assign(loading: false)
        # else
        socket =
          socket
          |> assign(data: data)
          |> assign_total_count(total_count)
          |> assign(column_order: visible_columns)
          |> assign(loading: false)
          |> assign(filter_querys: filters)
          |> assign(columns_visibility: new_visibility)

        # end

        {:noreply, socket}
      end

      # Función para manejar la visibilidad de todas las columnas
      defp handle_show_or_hide_columns(socket, new_visibility) do
        Debug.print(new_visibility, label: "HIDE O SHOW ALL COLUMNS")
        all_false = Enum.all?(new_visibility, fn {_, visible} -> not visible end)

        socket =
          if all_false do
            socket
            |> assign(columns_visibility: new_visibility)
            |> assign(filter_querys: %{})
            |> assign(column_order: [])
          else
            column_order = socket.assigns.initial_column_order
            priority_columns = socket.assigns.priority_columns
            params = merge_and_sanitize_params(socket)
            cadena = Map.get(socket.assigns, :cadena, false)
            # ENUM --------------------------------------------------------------
            report_id = Map.get(socket.assigns, :report_id, "")
            id_usuario = socket.assigns.idusuario
            columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
            last_params = Map.get(socket.assigns, :last_params, %{})
            id_sucursal = socket.assigns.current_user.idsucursal

            log_params = %{
              live_action: socket.assigns.live_action,
              params: params,
              report_id: report_id,
              id_usuario: id_usuario,
              id_sucursal: id_sucursal,
              last_params: last_params
            }

            # --------------------------------------------------------------------

            Debug.print(column_order, label: "COLUMN ORDER HIDE O SHOW ALL COLUMNS")

            %{data: data, total_count: total_count} =
              if cadena do
                unquote(client_module).get_data_with_filters_priority_columns(%{
                  columns_visibility: new_visibility,
                  params: params,
                  filters_querys: %{},
                  priority_columns: priority_columns,
                  log_params: log_params
                })
              else
                unquote(client_module).get_data_with_filters_priority_columns(%{
                  columns_visibility: new_visibility,
                  params: params,
                  filters_querys: %{},
                  priority_columns: priority_columns
                })
              end

            socket
            |> assign(data: data)
            |> assign_total_count(total_count)
            |> assign(column_order: column_order)
            |> assign(loading: false)
            |> assign(filter_querys: %{})
            |> assign(columns_visibility: new_visibility)
          end

        {:noreply, socket}
      end

      # Función para manejar el guardado de la vista
      defp handle_save_view(socket) do
        has_a_view = socket.assigns.has_a_view
        filter_querys = socket.assigns.filter_querys
        params = merge_and_sanitize_params(socket)
        column_order = socket.assigns.column_order
        reporte = socket.assigns.reporte
        priority_columns = socket.assigns.priority_columns

        result =
          if !has_a_view do
            SaveViewTableClient.save_view(%{
              id_reporte: reporte,
              id_usuario: socket.assigns.idusuario,
              filter_querys: filter_querys,
              columns_visibility: socket.assigns.columns_visibility,
              sorting_data: params,
              column_order: column_order,
              priority_columns: priority_columns
            })
          else
            SaveViewTableClient.update_view(%{
              id_reporte: reporte,
              id_usuario: socket.assigns.idusuario,
              filter_querys: filter_querys,
              columns_visibility: socket.assigns.columns_visibility,
              sorting_data: params,
              column_order: column_order,
              priority_columns: priority_columns
            })
          end

        socket =
          case result do
            {:ok, _record} ->
              socket
              |> assign(has_a_view: true)
              |> put_flash(
                :info,
                if(has_a_view,
                  do: "Vista actualizada correctamente",
                  else: "Vista guardada correctamente"
                )
              )

            {:error, changeset} ->
              Debug.print(changeset, label: "Error al guardar la vista")

              socket
              |> put_flash(:error, "Error al guardar la vista")
          end

        {:noreply, socket}
      end

      # Función para manejar la información de los filtros
      def handle_info({:filter_table, params}, socket) do
        filters_query = socket.assigns.filter_querys
        priority_columns = socket.assigns.priority_columns

        valid_key = params[:column]

        is_valid_filter =
          Map.has_key?(filters_query, valid_key) && Map.keys(filters_query) == [valid_key]

        socket =
          if params[:values] == [] && is_valid_filter do
            Debug.print("BORRANDO FILTRO", label: "BORRANDO FILTRO")
            column = params[:column]
            filters_querys_update = Map.delete(socket.assigns.filter_querys, params[:column])
            params = merge_and_sanitize_params(socket)
            columns_visibility = socket.assigns.columns_visibility
            columns = Map.get(socket.assigns, :columns, [])
            report_id = Map.get(socket.assigns, :report_id, "")
            id_usuario = socket.assigns.idusuario
            columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
            last_params = Map.get(socket.assigns, :last_params, %{})
            cadena = Map.get(socket.assigns, :cadena, false)

            log_params = %{
              live_action: socket.assigns.live_action,
              params: params,
              report_id: report_id,
              id_usuario: id_usuario,
              last_params: last_params
            }

            Debug.print(filters_querys_update, label: "FILTER QUERYS []")

            priority_columns =
              unquote(client_module).get_priority_columns(
                Map.get(socket.assigns, :report_id, "-1")
              )

            %{data: data, total_count: total_count} =
              if cadena do
                unquote(client_module).get_data_with_filters_priority_columns(%{
                  columns_visibility: columns_visibility,
                  params: params,
                  filters_querys: filters_querys_update,
                  priority_columns: priority_columns,
                  log_params: log_params
                })
              else
                unquote(client_module).get_data_with_filters_priority_columns(%{
                  columns_visibility: columns_visibility,
                  params: params,
                  filters_querys: filters_querys_update,
                  priority_columns: priority_columns
                })
              end

            {socket, data} =
              if cadena do
                total_row =
                  unquote(client_module).calculate_total(
                    data,
                    columns_with_total,
                    columns_visibility
                  )

                socket = assign(socket, total_row: total_row, last_params: params)
                {socket, data}
              else
                {socket, data}
              end

            clean_filters(socket)

            socket
            |> assign(data: data)
            |> assign_total_count(total_count)
            |> assign(filter_querys: %{})
            |> assign(priority_columns: priority_columns)
          else
            socket
            |> search_request(
              params[:column],
              params[:values],
              params[:action],
              params[:value_to_remove]
            )
          end

        {:noreply, socket}
      end

      def handle_info({:filter_search, %{column: column, value_search: value_search}}, socket) do
        handle_filter_search(socket, column, value_search)
      end

      def handle_info(
            {:filter_search_by_range,
             %{values_search_range: values_search_range, column: column}},
            socket
          ) do
        handle_filter_search_by_range(socket, column, values_search_range)
      end

      def handle_info(
            {:delete_range_filters,
             %{column: column, remove: remove, values_search_range: values_search_range}},
            socket
          ) do
        handle_delete_range_filters(socket, column, remove, values_search_range)
      end

      def handle_info({:show_columns, %{value: new_visibility, column: column}}, socket) do
        handle_show_columns(socket, new_visibility, column)
      end

      def handle_info({:show_or_hide_columns, %{value: new_visibility}}, socket) do
        handle_show_or_hide_columns(socket, new_visibility)
      end

      def handle_info({:save_view}, socket) do
        handle_save_view(socket)
      end

      # Función para manejar eventos
      def handle_event("delete_filters", _params, socket) do
        clean_all_filters_selected(socket)

        priority_columns =
          unquote(client_module).get_priority_columns(Map.get(socket.assigns, :report_id, "-1"))

        columns_visibility = socket.assigns.columns_visibility
        params = merge_and_sanitize_params(socket)
        report_id = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        last_params = Map.get(socket.assigns, :last_params, %{})
        current_user = socket.assigns.current_user
        id_sucursal = current_user.idsucursal
        cadena = Map.get(socket.assigns, :cadena, false)

        # esta asignacion justamente aqui hace que last_params siempre guarde los parametros anteriores a params.
        socket = socket |> assign(:last_params, params)

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          id_sucursal: id_sucursal,
          last_params: last_params
        }

        # Define los parámetros permitidos para eliminación
        removable_keys = [:id, :start_date, :end_date]

        # Iterar y filtrar solo los parámetros que se pueden eliminar
        filtered_params =
          Enum.reduce(params, %{}, fn {key, value}, acc ->
            if key in removable_keys do
              acc
            else
              Map.put(acc, key, value)
            end
          end)

        filter_querys = unquote(client_module).build_filters_from_input(filtered_params)

        Debug.print(filter_querys, label: "FILTERS QUERY DELETE FILTERS")

        opts = filtered_params

        %{data: data, total_count: total_count} =
          if cadena do
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filter_querys,
              priority_columns: priority_columns,
              log_params: log_params
            })
          else
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filter_querys,
              priority_columns: priority_columns
            })
          end

        clean_filters(socket)

        {socket, data} =
          if cadena do
            total_row =
              unquote(client_module).calculate_total(data, columns_with_total, columns_visibility)

            socket = assign(socket, total_row: total_row)
            {socket, data}
          else
            {socket, data}
          end

        socket =
          socket
          |> assign(data: data)
          |> assign_total_count(total_count)
          |> assign(filter_querys: %{})
          |> assign(priority_columns: priority_columns)
          |> assign(filter: %{})

        {:noreply, socket}
      end

      def handle_event("export-xlsx", _map, socket) do
        max_page_size_limit = 20000
        params = merge_and_sanitize_params(socket)
        columns_visibility = socket.assigns.columns_visibility
        priority_columns = socket.assigns.priority_columns

        cadena = Map.get(socket.assigns, :cadena, false)
        report_id = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        filter_querys = socket.assigns.filter_querys

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          columns_with_total: columns_with_total
        }

        # Obtener el total de elementos
        total_count =
          if cadena do
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: Map.put(params, :page_size, 1),
              filters_querys: socket.assigns.filter_querys,
              priority_columns: priority_columns,
              log_params: log_params
            })
            |> Map.get(:total_count)
          else
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: Map.put(params, :page_size, 1),
              filters_querys: socket.assigns.filter_querys,
              priority_columns: priority_columns
            })
            |> Map.get(:total_count)
          end

        # Validar si el total de registros es 0
        if total_count == 0 do
          socket =
            socket
            |> push_event("toggle-file-export-loading", %{})
            |> put_flash(:error, "No se puede exportar datos vacíos.")

          {:noreply, socket}
        else
          # Calcula el número de bloques de página con el límite definido
          page_size_blocks = div(total_count + max_page_size_limit - 1, max_page_size_limit)

          # Obtener datos en paralelo para todas las páginas
          transfers =
            1..page_size_blocks
            |> Enum.map(fn page ->
              Task.async(fn ->
                page_params =
                  params
                  |> Map.put(:page, page)
                  |> Map.put(:page_size, max_page_size_limit)

                if cadena do
                  case unquote(client_module).get_data_with_filters_priority_columns(%{
                         columns_visibility: columns_visibility,
                         params: page_params,
                         filters_querys: socket.assigns.filter_querys,
                         priority_columns: priority_columns,
                         log_params: log_params
                       }) do
                    %{data: data, total_count: _total_count} -> data
                  end
                else
                  case unquote(client_module).get_data_with_filters_priority_columns(%{
                         columns_visibility: columns_visibility,
                         params: page_params,
                         filters_querys: socket.assigns.filter_querys,
                         priority_columns: priority_columns
                       }) do
                    %{data: data, total_count: _total_count} -> data
                  end
                end
              end)
            end)
            |> Enum.map(fn task ->
              try do
                Task.await(task, 10000)
              rescue
                _ -> {:error, "No se pudo cargar el archivo."}
              end
            end)
            |> Enum.filter(&(&1 != {:error, "No se pudo cargar el archivo."}))
            |> List.flatten()

          # Configurar el socket según los resultados obtenidos
          socket =
            if transfers == [] do
              socket
              |> push_event("toggle-file-export-loading", %{})
              |> put_flash(:error, "No se pudo exportar el archivo.")
            else
              socket
              |> push_event("export-file-payload", %{data: transfers})
            end

          {:noreply, socket}
        end
      end

      # Función para asignar filtros a la tabla
      defp assign_filters_table(socket) do
        cadena = Map.get(socket.assigns, :cadena, false)

        socket =
          if cadena do
            params = merge_and_sanitize_params(socket)
            report_id = Map.get(socket.assigns, :report_id, "")
            id_usuario = socket.assigns.idusuario
            columns_with_total = Map.get(socket.assigns, :columns_with_total, [])

            log_params = %{
              live_action: socket.assigns.live_action,
              params: params,
              report_id: report_id,
              id_usuario: id_usuario,
              columns_with_total: columns_with_total
            }

            result = unquote(client_module).data_init_filters(log_params)

            socket
            |> assign(initial_filters: result)
            |> assign(filters: result)
          else
            result = unquote(client_module).data_init_filters()
            # result = catch_null_values(result)
            socket
            |> assign(initial_filters: result)
            |> assign(filters: result)
          end

        socket
      end

      # Función para cargar la vista guardada
      defp load_save_view(socket, params) do
        reporte = socket.assigns.reporte
        result = SaveViewTableClient.get_view_by_id_usuario(socket.assigns.idusuario, reporte)
        default_priority_columns = socket.assigns.priority_columns
        default_columns_visibility = socket.assigns.columns_visibility
        default_column_order = socket.assigns.column_order

        if result do
          case result do
            %Playground.Schemas.DatatableStructures.SaveViewTable{
              filter_querys: filter_querys_json,
              columns_visibility: columns_visibility_json,
              sorting_data: sorting_data_json,
              column_order: column_order_json,
              priority_columns: priority_columns
            } ->
              filter_querys = Jason.decode!(filter_querys_json)
              columns_visibility = Jason.decode!(columns_visibility_json)
              sorting_data = Jason.decode!(sorting_data_json)
              column_order = Jason.decode!(column_order_json)
              priority_columns = Jason.decode!(priority_columns)
              params_data = merge_and_sanitize_params(socket)
              sorting_data = update_sorting_data(sorting_data, params)

              send_params =
                if params != %{} do
                  params_data
                else
                  sorting_data
                  |> Enum.map(fn {k, v} ->
                    {String.to_atom(k), if(k == "sort_dir", do: String.to_atom(v), else: v)}
                  end)
                  |> Enum.into(%{})
                end

              filter_querys = Map.merge(socket.assigns.filter_querys, filter_querys)

              # Merge Priority Columns
              priority_columns =
                default_priority_columns
                |> Enum.reduce(%{}, fn {category, default_category_map}, acc ->
                  # Obtener el mapa de la categoría en priority_columns, si existe
                  category_priority_map = Map.get(priority_columns, category, %{})

                  # Fusionar los valores de las claves dentro de la categoría
                  merged_category_map =
                    default_category_map
                    |> Enum.reduce(%{}, fn {key, default_value}, merged_acc ->
                      # Tomar el valor de priority_columns si existe, de lo contrario usar el default
                      final_value = Map.get(category_priority_map, key, default_value)
                      Map.put(merged_acc, key, final_value)
                    end)

                  # Agregar la categoría fusionada al acumulador
                  Map.put(acc, category, merged_category_map)
                end)

              Debug.print(priority_columns, label: "PRIORIDAD DB")

              # Merge Column Visibility
              columns_visibility =
                default_columns_visibility
                |> Enum.reduce(%{}, fn {key, default_value}, acc ->
                  # Verificar si la clave está en columns_visibility
                  value =
                    if Map.has_key?(columns_visibility, key) do
                      # Si la clave está en ambos, tomar el valor de columns_visibility
                      Map.get(columns_visibility, key)
                    else
                      # Si la clave no está en columns_visibility, mantener su valor original de default_columns_visibility
                      default_value
                    end

                  # Agregar la clave y su valor al acumulador
                  Map.put(acc, key, value)
                end)

              Debug.print(default_column_order, label: "DEFAULT COLUMN ORDER")
              Debug.print(column_order, label: "DB COLUMN ORDER")
              Debug.print(columns_visibility, label: "COLUMNS")

              # Merge Column Order
              column_order =
                column_order
                # Solo mantener las columnas que están en default_column_order
                |> Enum.filter(fn col -> col in default_column_order end)
                # Agregar las columnas de default_column_order que faltan
                |> Kernel.++(default_column_order -- column_order)
                # Eliminar duplicados
                |> Enum.uniq()

              Debug.print(column_order, label: "COLUMN ORDER")

              socket =
                if filter_querys === %{} do
                  Debug.print(filter_querys, label: "FILTER QUERYS VACIO")

                  socket
                  |> assign(filter_querys: %{})
                  |> assign(columns_visibility: columns_visibility)
                  |> assign(priority_columns: priority_columns)
                  |> assign(has_a_view: true)
                  |> assign(sorting: send_params)
                  |> assign(column_order: column_order)
                else
                  Debug.print(filter_querys, label: "FILTER QUERYS ")

                  update_filter_tables(filter_querys, socket)

                  socket
                  |> assign(filter_querys: filter_querys)
                  |> assign(columns_visibility: columns_visibility)
                  |> assign(has_a_view: true)
                  |> assign(sorting: send_params)
                  |> assign(column_order: column_order)
                end

            _ ->
              socket
          end
        else
          Debug.print("No se cargó la vista guardada", label: "No se cargó la vista guardada")
          update_filter_querys(socket, result)
        end
      end

      # Función para actualizar los datos de ordenamiento
      defp update_sorting_data(sorting_data, params) do
        Map.merge(sorting_data, %{
          "sort_by" => Map.get(params, "sort_by", sorting_data["sort_by"]),
          "sort_dir" => Map.get(params, "sort_dir", sorting_data["sort_dir"])
        })
      end

      # Función para actualizar las tablas de filtros
      defp update_filter_tables(filter_querys, socket) do
        filter_querys
        |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "Rango por ") end)
        |> Enum.each(fn {key, value} ->
          range_value = List.first(value)
          column_to_use = key |> String.split() |> List.last()
        end)

        Debug.print(filter_querys, label: "FILTERS QUERY UPDATE FILTER TABLES")

        Enum.each(filter_querys, fn {column, values} ->
          init_column_data =
            Map.get(socket.assigns.initial_filters, String.to_atom(column), [])

          Debug.print(init_column_data, label: "INIT COLUMN DATA")
          Debug.print(values, label: "VALUES")

          send_update(PlaygroundWeb.LiveComponents.FilterTables,
            id: "filter-#{column}",
            selected_values: values,
            column_data: init_column_data
          )
        end)
      end

      # Función para actualizar los filtros
      defp update_filter_querys(socket, result) do
        filter_querys = socket.assigns.filter_querys

        Enum.each(filter_querys, fn {column, values} ->
          init_column_data =
            Map.get(socket.assigns.initial_filters, String.to_atom(column), [])

          send_update(PlaygroundWeb.LiveComponents.FilterTables,
            id: "filter-#{column}",
            selected_values: values || [],
            column_data: init_column_data
          )
        end)

        socket =
          if result do
            socket
            |> assign(has_a_view: true)
          else
            socket
            |> assign(has_a_view: false)
          end

        socket
      end

      # Función para manejar las acciones de los filtros eliminar, agregar y limpiar valores de una columna
      defp search_request(socket, column, values, action, value_to_remove) do
        normalized_values = normalize_values(values)

        filters =
          Map.get(socket.assigns, :filter_querys, %{}) |> Map.put(column, normalized_values)

        socket = assign(socket, filter_querys: filters)

        filters_update =
          case action do
            :remove ->
              handle_remove_action(socket, column, value_to_remove, filters)

            :add ->
              filters

            :clean ->
              handle_clean_action(socket, column, filters)
          end

        update_filters(socket, column, filters_update)
      end

      defp handle_remove_action(socket, column, value_to_remove, filters) do
        params_url = merge_and_sanitize_params(socket)
        cadena = Map.get(socket.assigns, :cadena, false)

        column =
          if cadena do
            column
          else
            case is_binary(column) do
              true ->
                try do
                  String.to_existing_atom(column)
                rescue
                  ArgumentError -> column
                end

              false ->
                column
            end
          end

        if is_binary(column) and String.starts_with?(column, "Rango por ") do
          case Map.get(filters, column) do
            nil ->
              filters

            current_values when is_list(current_values) ->
              updated_values =
                Enum.reject(current_values, fn value -> value == value_to_remove end)

              if updated_values == [] do
                Map.delete(filters, column)
              else
                Map.put(filters, column, updated_values)
              end
          end
        else
          case Map.get(params_url, column) do
            ^value_to_remove ->
              Map.update(filters, column, [value_to_remove], fn existing_values ->
                [value_to_remove | existing_values]
              end)

            _ ->
              valid_key = column
              is_valid_filter = Map.has_key?(filters, valid_key) and filters[valid_key] == []
              if is_valid_filter, do: Map.delete(filters, valid_key), else: filters
          end
        end
      end

      defp handle_clean_action(socket, column, _filters) do
        filters_update =
          Map.delete(socket.assigns.filter_querys, column) |> Map.delete("Rango por #{column}")

        filters_update
      end

      defp update_filters(socket, column, filters_update) do
        Debug.print(filters_update, label: "FILTERS QUERY UPDATE FILTERS")

        # filtrado de valores vacios []
        filters_update =
          filters_update
          |> Enum.filter(fn {_key, values} -> values != [] end)
          |> Enum.into(%{})

        Debug.print(filters_update, label: "FILTERS QUERY UPDATE FILTERS")

        params = merge_and_sanitize_params(socket)
        filter_list = socket.assigns.data
        priority_columns = socket.assigns.priority_columns
        columns_visibility = socket.assigns.columns_visibility
        report_id = Map.get(socket.assigns, :report_id, "")
        id_usuario = socket.assigns.idusuario
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        last_params = Map.get(socket.assigns, :last_params, %{})
        cadena = Map.get(socket.assigns, :cadena, false)
        current_user = socket.assigns.current_user
        id_sucursal = current_user.idsucursal

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          id_sucursal: id_sucursal,
          last_params: last_params
        }

        Debug.print(filters_update, label: "FILTERS UPDATE")

        # este casos solo es aplicable cuando la pagina no es = 1 y solo hay un filtro con un valor
        if Map.get(params, :page) != 1 && map_size(filters_update) == 1 do
          case Map.values(filters_update) do
            [[_]] ->
              Debug.print("ENTRO AQUI 1", label: "ENTRO AQUI 1")
              opts = PaginationForm.default_values()

              priority_columns =
                unquote(client_module).get_priority_columns(
                  Map.get(socket.assigns, :report_id, "-1")
                )

              send(self(), {:update, opts})

              socket
              |> assign(filter_querys: filters_update)
              |> assign(priority_columns: priority_columns)
              |> assign(loading: true)

            _ ->
              socket
          end
        end

        if Map.get(params, :page) != 1 && filter_list == [] do
          Debug.print("ENTRO AQUI 2", label: "ENTRO AQUI 2")
          opts = PaginationForm.default_values()

          priority_columns =
            unquote(client_module).get_priority_columns(Map.get(socket.assigns, :report_id, "-1"))

          send(self(), {:update, opts})

          socket
          |> assign(filter_querys: filters_update)
          |> assign(priority_columns: priority_columns)
        else
          Debug.print(filters_update, label: "ENTRO AQUI 3")

          priority_columns =
            if filters_update == %{} do
              unquote(client_module).get_priority_columns(
                Map.get(socket.assigns, :report_id, "-1")
              )
            else
              priority_columns
            end

          %{data: data, total_count: total_count} =
            if cadena do
              unquote(client_module).get_data_with_filters_priority_columns(%{
                columns_visibility: columns_visibility,
                params: params,
                filters_querys: filters_update,
                priority_columns: priority_columns,
                log_params: log_params
              })
            else
              unquote(client_module).get_data_with_filters_priority_columns(%{
                columns_visibility: columns_visibility,
                params: params,
                filters_querys: filters_update,
                priority_columns: priority_columns
              })
            end

          init_column_data = get_column_data(socket, column)

          send_update(PlaygroundWeb.LiveComponents.FilterTables,
            id: "filter-#{column}",
            selected_values: filters_update[column] || [],
            column_data: init_column_data || []
          )

          {socket, data} =
            if socket.assigns.cadena do
              total_row =
                unquote(client_module).calculate_total(
                  data,
                  columns_with_total,
                  columns_visibility
                )

              socket = assign(socket, total_row: total_row, last_params: params)
              {socket, data}
            else
              {socket, data}
            end

          socket
          |> assign(filter_querys: filters_update)
          |> assign(priority_columns: priority_columns)
          |> assign(data: data)
          |> assign_total_count(total_count)
        end
      end

      defp normalize_values(values) do
        case values do
          value when is_list(value) -> value
          single_value -> [single_value]
        end
      end

      defp clean_all_filters_selected(socket) do
        Debug.print("clean_all_filters_selected")
        filters = get_clean_filters(socket)

        Enum.each(filters, fn {filter_id, update_params} ->
          send_update(
            PlaygroundWeb.LiveComponents.FilterTables,
            Keyword.merge([id: "filter-#{filter_id}"], Map.to_list(update_params))
          )
        end)

        {:ok, socket}
      end

      defp assign_filter(socket, overrides \\ %{}) do
        assign(socket, filter: unquote(filter_utils_module).default_values(overrides))
      end

      defp assign_sorting(socket, overrides \\ %{}) do
        opts = Map.merge(call_sorting_default_values(), overrides)
        assign(socket, sorting: opts)
      end

      defp assign_data(socket) do
        Debug.print("------------- ASSIGN DATA ------------------------")
        filters_querys = socket.assigns.filter_querys
        priority_columns = socket.assigns.priority_columns
        columns_visibility = socket.assigns.columns_visibility
        params = merge_and_sanitize_params(socket)
        Debug.print(params, label: "PARAMS IN ASSIGN DATA")
        columns_with_total = Map.get(socket.assigns, :columns_with_total, [])
        last_params = Map.get(socket.assigns, :last_params, %{})

        # esta asignacion justamente aqui hace que last_params siempre guarde los parametros anteriores a params.
        socket = socket |> assign(:last_params, params)

        Debug.print(last_params, label: "LAST PARAMS IN ASSIGN DATA")

        Debug.print(filters_querys, label: "FILTERS QUERY ASSIGN DATA ")

        # ENUM HELPERS
        id_usuario = socket.assigns.idusuario
        report_id = Map.get(socket.assigns, :report_id, "")
        cadena = Map.get(socket.assigns, :cadena, false)
        current_user = socket.assigns.current_user
        id_sucursal = current_user.idsucursal

        log_params = %{
          live_action: socket.assigns.live_action,
          params: params,
          report_id: report_id,
          id_usuario: id_usuario,
          id_sucursal: id_sucursal,
          last_params: last_params
        }

        include_keys = unquote(client_module).get_incluir_params_busqueda_final()

        include_keys =
          if cadena do
            include_keys
          else
            Enum.map(include_keys, &String.to_atom(&1))
          end

        params_filters = Map.drop(params, include_keys)
        new_filters_querys = unquote(client_module).build_filters_from_input(params_filters)
        Debug.print(new_filters_querys, label: "NEW FILTERS QUERY")

        # evitar filtros duplicados, caso aplicable es cuando filtras varias veces por rango de fecha en los filtros superiores, esto evita que el rango anterior no se siga aplicando en filter querys
        filters_querys =
          elimination_duplicate_parameters(last_params, params, filters_querys, socket)

        Debug.print(filters_querys, label: "FILTERS QUERY ELIMINATION DUPLICATE PARAMETERS")

        # esto sobreescribe los filtros cuando hay claves nuevas en params esto ayuda para que cuando ya habia filtros aplicados pero aplicados uno directamente desde params los filtros anteriores se eliminan y los filtros aplicados por params seran los unicos aplicados
        filters_querys = override_filters(params, last_params, filters_querys, socket)
        Debug.print(filters_querys, label: "FILTERS QUERY OVERRIDE FILTERS")

        filters_querys =
          Map.merge(filters_querys, new_filters_querys, fn _key, old_val, new_val ->
            Enum.uniq(old_val ++ new_val)
          end)

        Debug.print(filters_querys, label: "FILTERS QUERY MERGE")

        filters_querys = catch_null_values(filters_querys)
        Debug.print(filters_querys, label: "FILTERS QUERY CATCH NULL VALUES")

        params = Map.drop(params, [:id])

        %{data: data, total_count: total_count} =
          if cadena do
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filters_querys,
              priority_columns: priority_columns,
              log_params: log_params
            })
          else
            unquote(client_module).get_data_with_filters_priority_columns(%{
              columns_visibility: columns_visibility,
              params: params,
              filters_querys: filters_querys,
              priority_columns: priority_columns
            })
          end

        {socket, data} =
          if cadena do
            total_row =
              unquote(client_module).calculate_total(data, columns_with_total, columns_visibility)

            socket = assign(socket, total_row: total_row)
            {socket, data}
          else
            {socket, data}
          end

        socket =
          socket
          |> assign(data: data)
          |> assign(filter_querys: filters_querys)
          |> assign_total_count(total_count)

        send_update(PlaygroundWeb.LiveComponents.FilterQuerys,
          id: "filters_querys",
          filter_querys: filters_querys
        )

        # Filtrar y enviar actualización al componente FilterTables
        if filters_querys != %{} do
          filters_querys
          |> Enum.each(fn {column, values} ->
            if String.starts_with?(to_string(column), "Rango por") do
              column_to_use = String.replace(to_string(column), "Rango por ", "")

              column_to_use =
                if cadena, do: column_to_use, else: String.to_existing_atom(column_to_use)

              send_update(PlaygroundWeb.LiveComponents.FilterTables,
                id: "filter-#{column_to_use}",
                values_search_range: values || [],
                column_data: socket.assigns.filters[column_to_use] || []
              )
            else
              column =
                if cadena,
                  do: column,
                  else: (is_binary(column) && String.to_existing_atom(column)) || column

              send_update(PlaygroundWeb.LiveComponents.FilterTables,
                id: "filter-#{to_string(column)}",
                selected_values: values || [],
                column_data: socket.assigns.filters[column] || []
              )
            end
          end)
        else
          if !cadena do
            clean_filters(socket)
          end
        end

        Debug.print("------------- END ASSIGN DATA ------------------------")

        socket
      end

      defp assign_pagination(socket, overrides \\ %{}) do
        assign(socket, pagination: PaginationForm.default_values(overrides))
      end

      defp assign_total_count(socket, total_count) do
        update(socket, :pagination, fn pagination ->
          %{pagination | total_count: total_count}
        end)
      end

      defp maybe_reset_pagination(overrides) do
        if unquote(filter_utils_module).contains_filter_values?(overrides) do
          Map.put(overrides, :page, 1)
        else
          overrides
        end
      end

      defp merge_and_sanitize_params(socket, overrides \\ %{}) do
        %{sorting: sorting, filter: filter, pagination: pagination} = socket.assigns
        overrides = maybe_reset_pagination(overrides)

        %{}
        |> Map.merge(sorting)
        |> Map.merge(filter)
        |> Map.merge(pagination)
        |> Map.merge(overrides)
        |> Map.drop([:total_count])
        |> Enum.reject(fn {_key, value} -> is_nil(value) end)
        |> Map.new()
      end

      defp parse_params(socket, params) do
        with {:ok, sorting_opts} <- call_sorting_parse(params),
             {:ok, filter_opts} <- unquote(filter_utils_module).parse(params),
             pagination_values_override <- PaginationForm.default_values(),
             {:ok, pagination_opts} <- PaginationForm.parse(params, pagination_values_override) do
          sorting_opts_map = Map.from_struct(sorting_opts)

          socket
          |> assign_filter(filter_opts)
          |> assign_sorting(sorting_opts_map)
          |> assign_pagination(pagination_opts)
        else
          error ->
            Debug.print(error, label: "Error al parsear los parámetros")

            socket
            |> assign_sorting()
            |> assign_filter()
            |> assign_pagination()
        end
      end

      # funcion que ayuda a eliminar de filter_querys los valores de los ultimos parametros aplicados
      defp elimination_duplicate_parameters(last_params, params, filter_querys, socket) do
        cadena = Map.get(socket.assigns, :cadena, false)

        Enum.reduce(Map.keys(last_params), filter_querys, fn key, acc ->
          cond do
            # Caso específico para rangos de fechas
            key in [:start_date, :end_date] ->
              last_start_date = Map.get(last_params, :start_date)
              last_end_date = Map.get(last_params, :end_date)
              current_start_date = Map.get(params, :start_date)
              current_end_date = Map.get(params, :end_date)

              if !cadena do
                clean_filters(socket)
              end

              # Validar si los rangos son diferentes
              if last_start_date != current_start_date or last_end_date != current_end_date do
                last_date_range = "#{last_start_date}/#{last_end_date}"
                current_date_range = "#{current_start_date}/#{current_end_date}"

                # Actualizar el filtro de "Rango por fecha"
                Map.update(acc, "Rango por fecha", [current_date_range], fn ranges ->
                  ranges
                  |> Enum.reject(&(&1 == last_date_range))
                  |> Enum.uniq()
                  |> Kernel.++([current_date_range])
                end)
              else
                acc
              end

            # Caso específico para :id
            key == :id ->
              last_id = Map.get(last_params, :id)
              current_id = Map.get(params, :id)

              if !cadena do
                clean_filters(socket)
              end

              if last_id != current_id do
                # Actualizar el filtro "embossing_file_id"
                Map.update(acc, "embossing_file_id", [current_id], fn ids ->
                  ids
                  |> Enum.reject(&(&1 == last_id))
                  |> Enum.uniq()
                  |> Kernel.++([current_id])
                end)
              else
                acc
              end

            # Caso por defecto (se puede expandir para otros campos)
            true ->
              acc
          end
        end)
      end

      # funcion para eliminar valores no validos
      defp catch_null_values(filter_querys) do
        invalid_values = ["/", nil]

        Enum.reduce(filter_querys, %{}, fn {key, values}, acc ->
          cleaned_values = Enum.reject(values, fn value -> value in invalid_values end)

          if cleaned_values == [] do
            acc
          else
            Map.put(acc, key, cleaned_values)
          end
        end)
      end

      defp override_filters(params, last_params, filters_querys, socket) do
        ignored_keys = [:sort_by, :page, :page_size, :sort_dir]
        validate_equals_values = [:id, :start_date, :end_date]
        cadena = Map.get(socket.assigns, :cadena, false)

        has_new_keys? =
          params
          |> Map.keys()
          |> Enum.any?(fn key ->
            # Verificar nuevas claves solo si last_params no está vacío
            # Claves existentes con valores diferentes
            # Campos que deben validar igualdad
            (map_size(last_params) > 0 and !Map.has_key?(last_params, key) and
               not Enum.member?(ignored_keys, key)) or
              (Map.has_key?(last_params, key) and params[key] != last_params[key] and
                 not Enum.member?(ignored_keys, key)) or
              Enum.any?(validate_equals_values, fn field ->
                field == key and Map.has_key?(last_params, field) and
                  params[field] == last_params[field]
              end)
          end)

        if has_new_keys? do
          if !cadena do
            clean_filters(socket)
          end

          %{}
        else
          filters_querys
        end
      end

      # esta funcion se creo porque en los casos donde filter_querys queda vacio o se sobreescriben los valores que hay por params se necesitaba actualizar los filtros seleccionados y con ellos su data para que solo aparecieran los seleccionados por params o que se vaciaran al quedar vacio filter_querys
      defp clean_filters(socket) do
        columns = unquote(client_module).get_keys_columns(socket)

        Enum.each(columns, fn column ->
          init_column_data = get_column_data(socket, column)

          send_update(PlaygroundWeb.LiveComponents.FilterTables,
            id: "filter-#{column}",
            selected_values: [],
            values_search_range: [],
            column_data: init_column_data || []
          )
        end)
      end

      # Esta funcion se encarga de añadir las claves faltantes en la lista de columns_order y el mapa de columns_visibility al momento de querer mostrar la columna de acciones
      defp add_missing_keys(list_visibility, order_columns, reporte, column, params) do
        keys =
          case reporte do
            1 ->
              ["ID Archivo Embozado", "IV", "Acciones"]

            x when x in [2, 3] ->
              ["Fecha", "ID Archivo Embozado", "Status", "Acciones"]

            4 ->
              if Map.has_key?(params, :id_file_embossing) and
                   params.id_file_embossing not in [nil, ""] do
                ["Consecutivo", "Sucursal"]
              else
                []
              end

            _ ->
              []
          end

        Debug.print(
          "------------------------ ADD MISSING KEYS ------------------------------------"
        )

        Debug.print(keys, label: "KEYS IN ADD MISSING KEYS")
        Debug.print(list_visibility, label: "VISIBILITY IN ADD MISSING KEYS")
        Debug.print(params, label: "PARAMS IN ADD MISSING KEYS")

        # validar que la columna exista en el mapa como valor false entonces se debe hacer el borrado
        is_false = Map.get(list_visibility, column, true)
        Debug.print(is_false, label: "VALID KEY IN ADD MISSING KEYS")

        keys =
          if !is_false do
            # eliminar columna de keys si es que esta viene como false para evitar activarla
            Enum.reject(keys, fn column -> column in keys end)
          else
            # filtrar las claves que no esten en la lista de visibilidad como true para evitar que al activar alguna columna, las keys se pasen a true si es que eran false
            Enum.filter(keys, fn clave -> Map.get(list_visibility, clave) != false end)
          end

        # aqui validamos que si la columna viene como true entonces le añadimos las claves fijas
        keys =
          if is_false do
            case {column, reporte} do
              {"Acciones", x} when x in [1] ->
                keys ++ ["ID Archivo Embozado", "IV"]

              {"Acciones", x} when x in [2, 3] ->
                keys ++ ["ID Archivo Embozado", "Status", "Fecha"]

              {"Consecutivo", 4} ->
                if Map.has_key?(params, :id_file_embossing) and
                     params.id_file_embossing not in [nil, ""] do
                  keys ++ ["Sucursal"]
                else
                  keys
                end

              _ ->
                []
            end
          else
            keys
          end

        Debug.print(keys, label: "COLUMN ORDER IN ADD MISSING KEYS")

        new_column_order =
          (order_columns ++ keys)
          |> Enum.uniq()

        Debug.print(new_column_order, label: "NEW COLUMN ORDER IN ADD MISSING KEYS")

        new_visibility =
          Map.new(list_visibility, fn {key, _value} ->
            {key, key in new_column_order}
          end)

        Debug.print(new_visibility, label: "NEW VISIBILITY IN ADD MISSING KEYS")

        Debug.print(
          "------------------------ END OF ADD MISSING KEYS ------------------------------------"
        )

        {new_visibility, new_column_order}
      end

      defp remove_keys(list_visibility, order_columns, reporte, column, params) do
        Debug.print("------------------------ REMOVE KEYS ------------------------------------")

        keys =
          case reporte do
            1 ->
              ["ID Archivo Embozado", "IV", "Acciones"]

            x when x in [2, 3] ->
              ["Fecha", "ID Archivo Embozado", "Status", "Acciones"]

            4 ->
              if Map.has_key?(params, :id_file_embossing) and
                   params.id_file_embossing not in [nil, ""] do
                ["Consecutivo", "Sucursal"]
              else
                []
              end

            _ ->
              []
          end

        # validar que la columna exista en el mapa como valor true entonces no se debe hacer el borrado
        is_true = Map.get(list_visibility, column, false)
        column_in_keys = Enum.member?(keys, column)

        Debug.print(is_true, label: "VALID KEY")

        {new_visibility, new_column_order} =
          if is_true || !column_in_keys do
            # si la columna es true y la columna no esta en keys entonces no se hace nada
            {list_visibility, order_columns}
          else
            has_invalid_key =
              Enum.any?(keys, fn key -> Map.get(list_visibility, key, true) == false end)

            Debug.print(has_invalid_key, label: "HAS INVALID KEY")

            new_column_order =
              if has_invalid_key do
                Enum.reject(order_columns, fn column -> column in keys end)
              else
                order_columns
              end

            new_visibility =
              Map.new(list_visibility, fn {key, _value} ->
                {key, key in new_column_order}
              end)

            Debug.print(new_visibility, label: "NEW VISIBILITY")
            Debug.print(new_column_order, label: "NEW COLUMN ORDER")
            {new_visibility, new_column_order}
          end

        Debug.print(
          "------------------------ END OF REMOVE KEYS ------------------------------------"
        )

        {new_visibility, new_column_order}
      end

      # modificar conversion de string a numerico
      def handle_event(
            "reorder_columns",
            %{"from" => from, "to" => to},
            socket
          ) do
        from_index = String.to_integer(from)
        to_index = String.to_integer(to)
        Debug.print(from_index, label: "from_index")
        Debug.print(to_index, label: "to_index")
        column_order = socket.assigns.column_order
        Debug.print(column_order, label: "column_order")

        if from_index != to_index and from_index < length(column_order) and
             to_index < length(column_order) do
          column = Enum.at(column_order, from_index)

          column_order =
            column_order
            |> List.delete_at(from_index)
            |> List.insert_at(to_index, column)

          {:noreply,
           socket
           |> assign(column_order: column_order)}
        else
          {:noreply, socket}
        end
      end

      # Función para obtener los filtros limpios
      defp get_clean_filters(socket) do
        unquote(client_module).get_clean_filters(socket)
      end

      # Función para determinar la clave a eliminar
      defp key_to_delete(column) do
        unquote(client_module).key_to_delete(column)
      end

      # Método genérico para llamar a SortingForm.default_values_embozado/0
      def call_sorting_default_values() do
        unquote(client_module).call_sorting_default_values()
      end

      # Método genérico para llamar a SortingForm.parse_embozado/1
      def call_sorting_parse(params) do
        unquote(client_module).call_sorting_parse(params)
      end
    end
  end
end
