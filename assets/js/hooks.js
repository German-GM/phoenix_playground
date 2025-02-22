const globalScrollEvents = {
  /** Habilita o deshabilita el scroll de forma global */
  customEvtRef: null,
  preventDefaultEvent(event) {
    event.preventDefault();
  },
  disable(customEvtRef) {
    document.body.style.pointerEvents = "none";
    document.body.style.overflow = "hidden";
    window.addEventListener(
      "scroll",
      customEvtRef || this.preventDefaultEvent,
      { passive: false }
    );
    window.addEventListener("wheel", customEvtRef || this.preventDefaultEvent, {
      passive: false,
    });
    window.addEventListener(
      "touchmove",
      customEvtRef || this.preventDefaultEvent,
      { passive: false }
    );
  },
  enable(customEvtRef) {
    document.body.style.pointerEvents = "auto";
    document.body.style.overflow = "";
    window.removeEventListener(
      "scroll",
      customEvtRef || this.preventDefaultEvent
    );
    window.removeEventListener(
      "wheel",
      customEvtRef || this.preventDefaultEvent
    );
    window.removeEventListener(
      "touchmove",
      customEvtRef || this.preventDefaultEvent
    );
  },
};

exports.InfiniteScroll = {
  mounted() {
    this.handleScroll = () => {
      if (this.el.scrollTop + this.el.clientHeight >= this.el.scrollHeight) {
        const inputElement = document.getElementById(this.el.id);

        if (inputElement) {
          this.pushEvent("infs-load-more", {
            query: inputElement.value,
            page: this.el.dataset.page,
          });
        }
      }
    };

    this.el.addEventListener("scroll", this.handleScroll);
  },
  updated() {
    this.el.dataset.page = this.el.dataset.page || 1;
  },
  destroyed() {
    this.el.removeEventListener("scroll", this.handleScroll);
  },
};

exports.UploadFile = {
  mounted() {
    this.handleChange = (e) => {
      const fileInput = e.target;

      if (fileInput.files.length > 0) {
        const envFilePrefix = this.el.dataset.envFilePrefix;
        if (envFilePrefix) {
          const fileName = fileInput.files[0].name;
          const fileNameMatchesPrefix = fileName.startsWith(envFilePrefix);

          if (!fileNameMatchesPrefix) {
            return this.pushEvent("flash", {
              type: "error",
              message: `El archivo debe comenzar con el prefijo "${envFilePrefix}"`,
            });
          }
        }

        const formId = this.el.closest("form").dataset.formId;
        const form = document.getElementById(formId);
        const formData = new FormData(form);

        // Obtener parámetros adicionales
        // const extraParam = form.dataset.extraParam
        const embossingFileId = this.el.dataset.embossingFileId;
        const userId = this.el.dataset.userId;
        // const target = this.el.dataset.uploadFileTarget;
        // Agregar parámetros adicionales al FormData si es necesario
        // formData.append("extra_param", extraParam)
        formData.append("embossing_file_id", embossingFileId);
        formData.append("user_id", userId);

        fetch(form.action, {
          method: "POST",
          body: formData,
          headers: {
            "X-CSRF-Token": document
              .querySelector("meta[name='csrf-token']")
              .getAttribute("content"),
          },
        })
          .then((response) => response.json())
          .then((data) => {
            if (data.status === "success") {
              this.pushEvent("flash", { type: "info", message: data.message });
              this.pushEvent("file_uploaded", {
                embossing_file_id: embossingFileId,
              });
            } else {
              this.pushEvent("flash", { type: "error", message: data.message });
            }
            // Restablecer el valor del input de archivo
            fileInput.value = "";
          })
          .catch((error) => {
            this.pushEvent("flash", {
              type: "error",
              message: "Error al subir el archivo.",
            });
            // Restablecer el valor del input de archivo
            fileInput.value = "";
          });
      }
    };

    this.el.addEventListener("change", this.handleChange);
  },
  updated() {},
  destroyed() {
    // Eliminar el listener del evento change
    this.el.removeEventListener("change", this.handleChange);
  },
};

exports.OpenPdfWithHeader = {
  mounted() {
    this.icon = this.el.querySelector(".icon");
    this.spinner = document.getElementById(`${this.el.id}-spinner`);

    this.handleClick = () => {
      const documentType = this.el.getAttribute("data-document-type");
      const socioId = this.el.getAttribute("data-socio-id");

      // Deshabilitar el botón, ocultar el icono y mostrar el spinner
      this.el.disabled = true;
      let icon = this.el.querySelector(".icon");
      let spinner = document.getElementById(`${this.el.id}-spinner`);

      // Ocultar el icono y mostrar el spinner
      icon.classList.add("hidden");
      spinner.classList.remove("hidden");

      if (documentType === "contrato_debito") {
        this.handlePrintContratoDebito(socioId);
      }
    };

    this.el.addEventListener("click", this.handleClick);

    this.handleEvent("print_contrato", (payload) => {
      const documentType = payload.documentType;

      if (documentType === "contrato_debito") {
        this.handlePrintContratoDebito(payload.socioId);
      }
    });
  },

  updated() {},
  destroyed() {
    // Eliminar los listeners de eventos
    this.el.removeEventListener("click", this.handleClick);
  },
  handlePrintContratoDebito(socioId) {
    const pdfPath = `/lynx/pdf/contrato_debito/${socioId}`;

    fetch(pdfPath, {
      method: "GET",
    })
      .then((response) => response.blob())
      .then((blob) => {
        const url = window.URL.createObjectURL(blob);
        window.open(url);
        this.el.disabled = false;
        this.icon.classList.remove("hidden");
        this.spinner.classList.add("hidden");
      })
      .catch((error) => console.error("Error:", error));
  },
};

/** Convierte los datos de fecha UTC a formato local */
exports.DateToLocal = {
  mounted() {
    const utcDate = this.el.dataset.utc;
    const localDate = new Date(utcDate).toLocaleString();
    this.el.innerText = localDate;
  },
  updated() {},
  destroyed() {},
};

exports.RestrictInputNumber = {
  mounted() {
    this.handleKeyPress = function (e) {
      if (!/[0-9]/.test(e.key)) {
        e.preventDefault();
      }
    };
    this.el.addEventListener("keypress", this.handleKeyPress);
  },
  destroyed() {
    this.el.removeEventListener("keypress", this.handleKeyPress);
  },
};

/** Obtiene todas las etiquetas con la clase "print_error_component" (exclusiva del componente <.print_error />)
 * y los imprime dentro de la etiqueta atada a este hook
 */
exports.DelegatePrintErrors = {
  mounted() {
    const thisEl = this.el;
    const errorElements = document.querySelectorAll(".print_error_component");

    for (let i = 0; i < errorElements.length; i++) {
      const errorElement = errorElements[i].innerHTML;
      thisEl.innerHTML += `<div>${errorElement}</div>`;
    }
  },
  updated() {
    this.mounted();
  },
  destroyed() {},
};

/** Previene el comportamiento default de un form al realizar el submit para exportar archivos.
 * Utilizado en el componente "file_exporter".
 * Con esto se evita que se "desmonten", y por ende, desactiven los eventos de otros hooks presentes en la vista actual.
 * Solo se debe utilizar 1 modo de envio de datos, ya sea enviandolos en un evento o pasando los datos al componente.
 */
exports.ExportFileForm = {
  mounted() {
    this.spinner = document.getElementById(`${this.el.id}-spinner`);
    this.exportBtn = document.getElementById(`${this.el.id}-btn`);

    /** Recibe los datos de forma dinamica con un evento liveview, para posteriormente enviarlos.
     * La propiedad "data" no debe establecerse en el componente si se usa esta forma
     * para cargar los datos, ya que de lo contrario se enviaran en el evento submit.
     */
    this.handleEvent("export-file-payload", (payload) => {
      const data = payload?.data || [];
      const formData = new FormData(this.el);
      formData.set("data", JSON.stringify(data));

      this.handleFileRequest(formData);
    });

    this.handleEvent("export-file-payload-component", (payload) => {
      if (this.el.id === `export-xlsx-${payload.id_component}`) {
        const data = payload?.data || [];
        const formData = new FormData(this.el);
        formData.set("data", JSON.stringify(data));

        this.handleFileRequest(formData);
      }
    });

    this.handleEvent("toggle-file-export-loading", () => {
      this.toggleLoader();
    });

    /** Evento submit estandar.
     * Se ejecuta antes de "handleEvent".
     * Se envian los datos solo si estos existen.
     */
    this.handleSubmit = (e) => {
      e.preventDefault();
      this.toggleLoader();
      const formData = new FormData(this.el);

      if (formData.has("data")) {
        this.handleFileRequest(formData);
      }
    };

    this.el.addEventListener("submit", this.handleSubmit);
  },
  updated() {},
  destroyed() {
    this.el.removeEventListener("submit", this.handleSubmit);
  },
  handleFileRequest(formData) {
    // const csrfToken = this.el.querySelector("[name='_csrf_token']").getAttribute("value");
    fetch(this.el.action, {
      method: this.el.method,
      body: formData,
      // headers: {
      //   "x-csrf-token": csrfToken
      // }
    })
      .then((response) => {
        if (!response.ok)
          throw "La respuesta de la petición solicitada ha fallado.";

        return response.blob();
      })
      .then((blob) => {
        // Manejar descarga de archivo
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");

        a.href = url;
        a.download = formData.get("filename");
        document.body.appendChild(a);

        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch((error) => console.error("Error:", error))
      .finally(() => {
        this.toggleLoader();
      });
  },
  toggleLoader() {
    this.spinner.classList.toggle("hidden");
    const disabled = Boolean(this.exportBtn.getAttribute("disabled"));
    !disabled && this.exportBtn.setAttribute("disabled", true);
    disabled && this.exportBtn.removeAttribute("disabled");
  },
};

/* Utilizado para seleccionar texto */
exports.SelectText = {
  mounted() {
    this.handleClick = () => {
      if (this.el.select) {
        this.el.select();
      } else {
        const range = document.createRange();
        range.selectNodeContents(this.el);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
      }
    };

    this.el.addEventListener("click", this.handleClick);
  },
  updated() {},
  destroyed() {
    this.el.removeEventListener("click", this.handleClick);
  },
};

/* Utilizado para copiar texto en conjunto con el componente "text_copy" */
exports.CopyText = {
  mounted() {
    let timeout;

    this.handleClick = () => {
      timeout && clearTimeout(timeout);
      const textToCopy = this?.el?.textContent?.trim() || "not_copied";

      // navigator.clipboard solo existe en entornos seguros (https o localhost). window.isSecureContext
      if (navigator.clipboard) {
        navigator.clipboard
          .writeText(textToCopy)
          .then(() => {
            timeout = this.showCopiedIndicator();
          })
          .catch((err) => {
            console.error("Error copying text: ", err);
          });
      }

      // Utilizar fallback de copiado no seguro
      else {
        const textArea = document.createElement("textarea");
        textArea.style.position = "absolute";
        textArea.style.left = "-999999px";
        document.body.appendChild(textArea);

        textArea.value = textToCopy;
        textArea.focus({ preventScroll: true });
        textArea.select();

        try {
          document.execCommand("copy");
          timeout = this.showCopiedIndicator();
        } catch (err) {
          console.error("Error copying text: ", err);
        } finally {
          document.body.removeChild(textArea);
        }
      }
    };

    this.el.addEventListener("click", this.handleClick);
  },
  showCopiedIndicator() {
    const copyMessage = document.getElementById(`copied_message_${this.el.id}`);
    copyMessage.classList.remove("hidden");

    return setTimeout(() => {
      copyMessage.classList.add("hidden");
    }, 2000);
  },
  updated() {},
  destroyed() {
    this.el.removeEventListener("click", this.handleClick);
  },
};

exports.DisableEnterKeyEvent = {
  mounted() {
    this.handleKeyDown = (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
      }
    };

    this.el.addEventListener("keydown", this.handleKeyDown);
  },
  updated() {},
  destroyed() {
    this.el.removeEventListener("keydown", this.handleKeyDown);
  },
};

exports.Accordion = {
  mounted() {
    const accordion_container_id = this.el.id;
    const only_one = this.el.dataset.onlyOne == "true";
    const multiple = this.el.dataset.multiple == "true";
    const open_all = this.el.dataset.openAll == "true";
    const open_default = this.el.dataset.openDefault;

    this.accordion_opened = {};
    this.header_btn_events = [];

    this.accordion_headers = document.querySelectorAll(
      `.${accordion_container_id}-lynxweb-accordion-header`
    );

    const accordion_containers = document.querySelectorAll(
      `.${accordion_container_id}-lynxweb-accordion-container`
    );

    // Abre todos los acordeones
    if (open_all) {
      this.accordion_headers.forEach((header, header_idx) => {
        const unique_header_id = `${accordion_container_id}-${header_idx}`;
        const container = header.nextElementSibling;

        this.accordion_opened[unique_header_id] = true;

        // header.classList.add("border-b");
        header.querySelector(".hero-chevron-down").classList.add("rotate-180");
        container.classList.remove("accordion-close");
      });
    }

    // Abre un acordeon especificado por nombre de encabezado
    else if (open_default) {
      // Si "open_default" existe y se pasa como booleano, abrir el primer acordeon
      if (open_default == "true") {
        const header = this.accordion_headers[0];
        const unique_header_id = `${accordion_container_id}-${0}`;
        const container = header.nextElementSibling;

        this.accordion_opened[unique_header_id] =
          container.classList.contains("accordion-close");

        // header.classList.add("border-b");
        header.querySelector(".hero-chevron-down").classList.add("rotate-180");
        container.classList.remove("accordion-close");
      }

      // De lo contrario abrir el acordeon especificado si el nombre coincide
      else {
        this.accordion_headers.forEach((header, header_idx) => {
          const unique_header_id = `${accordion_container_id}-${header_idx}`;
          const header_name = header.dataset.headerName;
          const container = header.nextElementSibling;

          if (header_name === open_default) {
            this.accordion_opened[unique_header_id] =
              container.classList.contains("accordion-close");

            // header.classList.add("border-b");
            header
              .querySelector(".hero-chevron-down")
              .classList.add("rotate-180");
            container.classList.remove("accordion-close");
          }
        });
      }
    }

    // Ciclo para establecer los eventos de los acordeones con su logica de apertura/cierre
    this.accordion_headers.forEach((header, header_idx) => {
      const unique_header_id = `${accordion_container_id}-${header_idx}`;
      const container = header.nextElementSibling;

      const header_btn_event = (evt) => {
        const clicked_id = evt.currentTarget.dataset.id;

        // Permite abrir un acordeon a la vez (por grupo)
        if (only_one) {
          this.accordion_opened = {};

          // Volver el icono de flecha a su estado original ("hero-chevron-down")
          this.accordion_headers.forEach((_header) => {
            const header_id = _header.dataset.id;

            if (clicked_id != header_id)
              _header
                .querySelector(".hero-chevron-down")
                .classList.remove("rotate-180");
          });

          // Cerrar todos los acordeones que esten abiertos
          accordion_containers.forEach((_container) => {
            const container_id = _container.dataset.id;

            if (
              !_container.classList.contains("accordion-close") &&
              clicked_id != container_id
            )
              _container.classList.add("accordion-close");
          });

          this.accordion_opened[unique_header_id] =
            container.classList.contains("accordion-close");

          // Abrir el acordeon seleccionado, agregando la rotacion 180deg de la flecha ("hero-chevron-down")
          header
            .querySelector(".hero-chevron-down")
            .classList.toggle("rotate-180");
          container.classList.toggle("accordion-close");
        }

        // Permite abrir/cerrar multiples acordeones sin restriccion. Este es el comportamiento default
        else if (multiple) {
          this.accordion_opened[unique_header_id] =
            container.classList.contains("accordion-close");

          // Abrir/cerrar el acordeon seleccionado, agregando/quitando la rotacion 180deg de la flecha ("hero-chevron-down")
          header
            .querySelector(".hero-chevron-down")
            .classList.toggle("rotate-180");
          container.classList.toggle("accordion-close");
        }

        // this.accordion_opened[unique_header_id]
        //   ? header.classList.add("border-b")
        //   : header.classList.remove("border-b");
      };

      header.addEventListener("click", header_btn_event);
      this.header_btn_events.push({ header, header_btn_event });
    });
  },
  /* Aqui "updated" preserva el estado de los acordeones, ya que si el contenido del slot "accordion"
  se actualiza (ej. al marcar un reporte como favorito), el componente se re-renderiza y vuelve a su
  estado inicial.
  NOTA: Usar phx-update="ignore" podria parecer una solucion, pero esto a su vez causa que el nodo donde
  se usa y sus nodos hijos no se actualicen visualmente en el DOM, por lo que de momento asi quedaria. */
  updated() {
    const accordion_container_id = this.el.id;

    this.accordion_headers.forEach((header, header_idx) => {
      const unique_header_id = `${accordion_container_id}-${header_idx}`;
      const container = header.nextElementSibling;

      if (this.accordion_opened[unique_header_id]) {
        // header.classList.add("border-b");
        header.querySelector(".hero-chevron-down").classList.add("rotate-180");
        container.classList.remove("accordion-close");
      }
    });
  },
  destroyed() {
    this.header_btn_events.forEach(({ header, header_btn_event }) =>
      header.removeEventListener("click", header_btn_event)
    );
  },
};

exports.Breadcrumbs = {
  mounted() {
    /**
     "parsed_paths" sirve para darle un mejor formato (ej. acentos) o un nombre mas completo a rutas
      específicas que lo necesiten, ademas de especificar si redireccionan a otra ruta o forzar el segmento
      para que no pueda redireccionar (ej. si solo sirve como un paso extra visual a otra ruta anidada).

     * Params de rutas
     * - name: Nombre de la ruta - requerido
     * - as_text: Poner el segmento de ruta como texto - opcional (tiene prioridad sobre "redirect")
     * - redirect: Ruta a redireccionar - opcional
     */
    const parsed_paths = {
      // RUTAS ESTÁNDAR
      "/debito": {
        name: "Administración de tarjetas",
      },
      "/concentrating_account_dock_one": {
        name: "Cuenta concentradora",
      },
      "/embozado": {
        name: "Solicitar lote embozado",
      },
      "/embozado/cards": {
        name: "Ver tarjetas",
        as_text: true,
      },
      "/embozado/stock_cards": {
        name: "Inventario",
      },
      "/embozado/uploaded_files": {
        name: "Archivos cargados",
      },

      "/embozado/assignments_embossing": {
        name: "Asignaciones",
      },
      "/configuration": {
        name: "Parámetros Generales del Sistema",
      },

      // CATALOGO DE DOCUMENTOS
      "/catalogo_documentos": {
        name: "Catálogo de Documentos",
      },
      "/catalogo_documentos/docs_socios": {
        name: "Documentos del socio",
      },
      "/catalogo_documentos/docs_credito": {
        name: "Documentos de crédito",
      },

      // REPORTES GENERALES
      "/reportes": {
        name: "Reportes generales",
        redirect: "/reportes",
      },

      "/reportes_generales": {
        name: "Reportes generales",
        redirect: "/reportes",
      },

      "/reportes_credito": {
        name: "Reportes créditos",
        redirect: "/reportes",
      },

      "/reportes_credito/consulta_domiciliaciones_a_credito": {
        name: "Consulta domiciliaciones a crédito",
      },

      "/reportes_credito/consulta_creditos_indicadores": {
        name: "Consulta créditos indicadores",
      },

      // REPORTES DOCK ONE
      "/reportes_dock_one": {
        name: "Reportes dock one",
        redirect: "/reportes",
      },
      "/reportes_dock_one/cards": {
        name: "Tarjetas embozadas",
      },
      "/reportes_dock_one/transactions_by_account_id": {
        name: "Transacciones por ID de cuenta",
      },
      "/reportes_dock_one/transactions_by_socio_number": {
        name: "Transacciones por número de socio",
      },
      "/reportes_dock_one/transactions_by_concentrating_account": {
        name: "Transacciones por cuenta concentradora",
      },

      // REPORTES MORPHEUS
      "/reportes_morpheus": {
        name: "Reportes morpheus",
        redirect: "/reportes",
      },
      "/reportes_morpheus/global_account_alias": {
        name: "General de cuentas - Global account alias",
      },
      "/reportes_morpheus/global_account_balance": {
        name: "General de cuentas - Global account balance",
      },
      "/reportes_morpheus/global_account_group_config": {
        name: "General de cuentas - Global account group config",
      },
      "/reportes_morpheus/global_account_sub_type_config": {
        name: "General de cuentas - Global account subtype config",
      },
      "/reportes_morpheus/global_account_alias2": {
        name: "Socios - Global account alias",
      },
      "/reportes_morpheus/global_persons_addresses": {
        name: "Socios - Global person addresses",
      },
      "/reportes_morpheus/global_persons_emails": {
        name: "Socios - Global person emails",
      },
      "/reportes_morpheus/global_persons_natural_persons": {
        name: "Socios - Global natural persons",
      },
      "/reportes_morpheus/global_persons_phones": {
        name: "Socios - Global persons phones",
      },
      "/reportes_morpheus/global_bam": {
        name: "Socios - Global bam",
      },
      "/reportes_morpheus/global_persons_documents": {
        name: "Socios - Global persons documents",
      },
      "/reportes_morpheus/global_account_alias3": {
        name: "Estado de cuenta - Global account alias",
      },
      "/reportes_morpheus/global_account_balance2": {
        name: "Estado de cuenta - Global account balance",
      },
      "/reportes_morpheus/global_account_group_config2": {
        name: "Estado de cuenta - Global account group config",
      },
      "/reportes_morpheus/global_account_sub_type_config2": {
        name: "Estado de cuenta - Global account subtype config",
      },
      "/reportes_morpheus/global_authorization": {
        name: "Estado de cuenta - Global authorization",
      },
      "/reportes_morpheus/global_persons_addresses2": {
        name: "Estado de cuenta - Global person addresses",
      },
      "/reportes_morpheus/global_persons_natural_persons2": {
        name: "Estado de cuenta - Global natural persons",
      },
      "/reportes_morpheus/global_card_scheme_instance": {
        name: "Estado de cuenta - Global card scheme instance",
      },
      "/reportes_morpheus/global_card_scheme_component": {
        name: "Estado de cuenta - Global card scheme component",
      },
      "/reportes_morpheus/global_authorization2": {
        name: "Conciliación - Global authorization",
      },
      "/reportes_morpheus/global_bam2": {
        name: "Conciliación - Global bam",
      },
      "/reportes_morpheus/global_cards": {
        name: "Embozado - Global cards",
      },
      "/reportes_morpheus/global_authorization3": {
        name: "Operaciones AUTH - Global authorization",
      },
      "/reportes_morpheus/global_bam3": {
        name: "Operaciones AUTH - Global bam",
      },
      "/reportes_morpheus/global_card_scheme_instance2": {
        name: "Operaciones AUTH - Global card scheme instance",
      },
      "/reportes_morpheus/global_card_scheme_step_instance": {
        name: "Operaciones AUTH - Global card scheme component",
      },
      "/reportes_morpheus/global_card_scheme_component2": {
        name: "Operaciones AUTH - Global card scheme step instance",
      },
    };

    // No mostrar el componente breadcrumb en las siguientes rutas
    const breadcrumbs_not_allowed_paths = ["/", "/dev", "/log_in", "/landing"];

    const path_segments = this.getPathSegments();

    const breadcrumbs_not_allowed = path_segments.some((path) =>
      breadcrumbs_not_allowed_paths.includes(path)
    );

    if (breadcrumbs_not_allowed) return;

    const breadcrumbs_HTML = this.buildBreadcrumbsHTML(
      path_segments,
      parsed_paths
    );

    // Insertar el HTML de las rutas al componente breadcrumbs
    this.el.insertAdjacentHTML("beforeend", breadcrumbs_HTML);

    // Visualizar componente breadcrumbs
    this.el.classList.add("mb-2");
    this.el.classList.replace("h-0", "h-[44px]");
    this.el.classList.replace("opacity-0", "opacity-100");
  },
  updated() {},
  destroyed() {},
  getPathSegments() {
    let path_builder = "";

    const pathname = window.location.pathname
      .split("/")
      .filter(Boolean)
      .map((path) => {
        /* Si ya existe la ruta base, se va agregando cada segmento
        de ruta al final hasta que termina el ciclo */
        if (path_builder) {
          path_builder = `${path_builder}/${path}`;
          return path_builder;
        }

        // Establece la ruta base
        path_builder = `/${path}`;
        return path_builder;
      });

    return pathname;
  },
  buildBreadcrumbsHTML(path_segments, parsed_paths) {
    const breadcrumb_separator = `
      <svg class="h-full w-6 flex-shrink-0 text-gray-200" viewBox="0 0 24 44" preserveAspectRatio="none" fill="currentColor" aria-hidden="true">
        <path d="M.293 0l22 22-22 22h1.414l22-22-22-22H.293z" />
      </svg>`;

    const breadcrumbs = path_segments
      .map((path, i, arr) => {
        let last_path = path.split("/").pop();

        last_path = last_path.charAt(0).toUpperCase() + last_path.slice(1);
        last_path = decodeURI(last_path);

        const breadcrumb_link =
          i === arr.length - 1 || parsed_paths[path]?.as_text
            ? `<span class="ml-4 text-sm font-medium text-gray-500 cursor-default">
          ${parsed_paths[path]?.name || last_path}
        </span>`
            : `<a href="${
                parsed_paths[path]?.redirect || path
              }" data-phx-link="redirect" data-phx-link-state="push" class="ml-4 text-sm font-medium text-gray-500 hover:text-gray-800 transition-colors duration-200 ease-out">
          ${parsed_paths[path]?.name || last_path}
        </a>`;

        return `
        <li class="flex">
          <div class="flex items-center">
            ${breadcrumb_separator}
            ${breadcrumb_link}
          </div>
        </li>
      `;
      })
      .join("");

    return breadcrumbs;
  },
};

/* TabManager - Hook reusable para componentes con comportamiento tipo Tab
Atributos y/o clases requeridas:
- Botones Tab -> attr: data-tab="tab-<numero>" | class: "tab-btn ..."
- Divs Contenido -> attr: id="tab-<numero>" | class: "tab-content ..."

Ejemplo de uso:
<div id="unique-id" phx-hook="TabManager">

  <button data-tab="tab-0" class="tab-btn">Tab 0</button>
  <div id="tab-0" class="tab-content">...</div>

  <button data-tab="tab-1" class="tab-btn">Tab 1</button>
  <div id="tab-1" class="tab-content">...</div>

  Etc...
</div>
*/
exports.TabManager = {
  mounted() {
    const tabs_component = this.el.dataset.tabsComponent == "true";

    const querySelectorTabBtn = `.${
      tabs_component ? this.el.id + "-" : ""
    }tab-hook`;

    const querySelectorTabContent = `.${
      tabs_component ? this.el.id + "-" : ""
    }content-hook`;

    // Tomar todos los botones y contenidos en el documento
    const tab_btns_doc = document.querySelectorAll(querySelectorTabBtn);
    const tab_contents_doc = document.querySelectorAll(querySelectorTabContent);

    // Tomar solo los botones dentro de el elemento padre al que este asignado el hook
    const tab_btns = this.el.querySelectorAll(querySelectorTabBtn);

    // Función para ocultar los contenidos y quitar los estilos activos
    const closeTabs = () => {
      tab_contents_doc.forEach((content) => {
        content.classList.add("hidden");
      });

      tab_btns_doc.forEach((tab) => {
        tab.classList.remove("active");
        tab.classList.add("inactive");
      });
    };

    // Detecta si hay un clic fuera de los elementos del menu de tabs o el contenido, si lo hay oculta el contenido y quita el estilo activo
    this.click_outside_evt = (event) => {
      const isOutsideTabs =
        !event.target.closest(querySelectorTabBtn) &&
        !event.target.closest(querySelectorTabContent);
      if (isOutsideTabs) closeTabs();
    };

    if (!tabs_component)
      document.addEventListener("click", this.click_outside_evt);

    // Listener de eventos para el comportamiento de los tabs y su contenido
    this.tab_btn_events = [];
    tab_btns.forEach((btn) => {
      const tab_btn_event = () => {
        const tabName = btn.dataset.tab;

        // Oculta el contenido de todas las pestañas y solo deja la del boton actual
        tab_contents_doc.forEach((content) => {
          if (content.id === tabName && content.classList.contains("hidden")) {
            content.classList.remove("hidden");
          } else {
            content.classList.add("hidden");
          }
        });

        // Quita el estilo activo de todos los botones de pestañas
        tab_btns_doc.forEach((tab) => {
          tab.classList.remove("active");
          tab.classList.add("inactive");
        });

        // Agrega el estilo activo al botón de pestaña actual
        btn.classList.remove("inactive");
        btn.classList.add("active");
      };

      btn.addEventListener("click", tab_btn_event);
      this.tab_btn_events.push({ btn, tab_btn_event });
    });
  },
  updated() {},
  destroyed() {
    document.removeEventListener("click", this.click_outside_evt);

    this.tab_btn_events.forEach(({ btn, tab_btn_event }) =>
      btn.removeEventListener("click", tab_btn_event)
    );
  },
};

exports.AutocompletePosition = {
  mounted() {
    this.autocompleteForm = this.el;
    this.autocompleteResults = this.el.querySelector(
      `#autocomplete-${this.el.id}-results`
    );

    this.updatePosition();

    this.onResize = () => this.updatePosition();
    this.onScroll = () => this.updatePosition();

    window.addEventListener("resize", this.onResize);
    window.addEventListener("scroll", this.onScroll);
  },
  updated() {
    this.updatePosition();
  },
  updatePosition() {
    let rect = this.autocompleteForm.getBoundingClientRect();
    let windowHeight = window.innerHeight;
    let spaceBelow = windowHeight - rect.bottom;
    let resultsHeight = this.autocompleteResults.offsetHeight;

    // Mover la caja hacia arriba si el espacio no es suficiente en la parte inferior
    if (spaceBelow < resultsHeight) {
      this.autocompleteResults.style.top = `-${resultsHeight}px`;
    }
    // De lo contrario mover la caja hacia abajo
    else {
      this.autocompleteResults.style.top = `${rect.height}px`;
    }
  },
  destroyed() {
    window.removeEventListener("resize", this.onResize);
    window.removeEventListener("scroll", this.onScroll);
  },
};

exports.AnimateFadeIn = {
  mounted() {
    this.el.classList.add("fade-in");
    setTimeout(() => {
      this.el.classList.remove("fade-in");
    }, 500);
  },
  updated() {},
  destroyed() {},
};

exports.WebSocketHook = {
  mounted() {
    // Escuchar eventos para conectar el WebSocket
    this.handleEvent("connect_websocket", () => {
      console.log("Connecting to WebSocket");
      this.connectWebSocket();
    });

    // Escuchar eventos para cerrar el WebSocket
    this.handleEvent("close_websocket", () => {
      console.log("Closing WebSocket connection-");
      this.closeWebSocket();
    });

    // Manejar el evento de foco
    window.addEventListener("focus", () => {
      console.log("Window focused");
      this.pushEvent("page_focused", { user_id: this.el.dataset.userId });
    });

    // Suscribirse al canal PubSub
    this.pushEvent("subscribe_to_pubsub", { user_id: this.el.dataset.userId });
  },
  connectWebSocket() {
    // Conectar al WebSocket
    this.socket = new WebSocket("ws://localhost:5055/lector");

    // Manejadores de eventos del WebSocket
    this.socket.onopen = () => {
      console.log("WebSocket connection opened");
    };

    this.handleEvent("send_message", (payload) => {
      // Se envía el payload al servidor "ws://localhost:5055/lector", el cual emitirá una respuesta en el evento "onmessage"
      console.log("Sending message to WS server:", payload);
      this.socket.send(JSON.stringify(payload));
    });

    this.socket.onmessage = (event) => {
      console.log("Message received from server: ", event.data);
      this.pushEvent("message_received", event.data);
      this.handleMessage(event.data);
    };

    this.socket.onerror = (error) => {
      console.error("WebSocket error:", error);
      this.pushEvent("server_disabled");
    };

    this.socket.onclose = () => {
      console.log("WebSocket connection closed");
      this.pushEvent("server_disabled");
    };
  },
  closeWebSocket() {
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
  },
  updated() {},
  destroyed() {
    // Cerrar la conexión WebSocket cuando el componente se destruya
    this.closeWebSocket();
  },
  handleMessage(data) {
    console.log("Handling received message:", data);
  },
};

exports.TableContainer = {
  mounted() {
    this.hasStickyHeader = this.el.dataset.stickyHeader == 'true';
    this.tableRoot = this.el.closest('.table-root');
    this.tableTempContainer = this.tableRoot.querySelector('.table-temp-container');
  },
  updated() {
    if (this.hasStickyHeader) {
      /* Si se actualiza la tabla, actualizar el atributo del contenedor temporal (sticky-header),
      esto es para que "this.observeNode(this.tableTempContainer)" en el hook "TableTrackFilterContentPosition"
      reaccione a la actualizacion del atributo, y haga el proceso necesario.

      Esto arregla un detalle en el cual si la página es > 1, al aplicar un filtro, el contenedor de filtros
      se "cortaba" porque al actualizarse la tabla, el hook "TableTrackFilterContentPosition"
      disparaba el "update" antes del renderizado de la tabla, por lo que la tabla se movía al contenedor
      temporal, pero el renderizado posterior volvía a poner la tabla en el contenedor original. */
      this.tableTempContainer.style.opacity = 'initial'; 
    }
  },
}

exports.TableTrackFilterContentPosition = {
  mounted() {},
  updated() {
    // Solo establecer el setup inicial cuando se actualice el componente del hook
    if (!this.initialUpdate) {
      this.initialUpdate = true;

      this.interval = null;
      this.maxWidthApp = 1536; // Establecido en app.html.heex (<main class="max-w-screen-2xl ...">)
      this.tableRoot = this.el.closest(".table-root");
      this.tableContainer = this.tableRoot.querySelector(".table-container");

      this.hasStickyHeader = this.tableContainer.dataset.stickyHeader == "true";
      if (this.hasStickyHeader) {
        this.tableTempContainer = this.tableRoot.querySelector(
          ".table-temp-container"
        );
      }

      this.limitScrollEventOnContentEvt = (e) => {
        if (this.dropdownContent && !this.dropdownContent.contains(e.target)) {
          e.preventDefault();
        }
      };
    }

    this.updateFilterContainerBehaviour();
  },
  destroyed() {
    this.enableScroll();
    window.removeEventListener("resize", this.handleContainerPosition);
    this.observer && this.observer.disconnect();
  },
  updateFilterContainerBehaviour() {
    this.toggleButton = this.el.querySelector(
      `.table-dropdown-toggle-${this.el.id}`
    );
    this.dropdownContent = this.el.querySelector(
      `.table-dropdown-content-${this.el.id}`
    );

    // Si la caja contenedora de filtros es visible, se agrega el evento de scroll a la tabla padre
    if (this.dropdownContent) {
      this.calculateFilterContainerXYPosition();

      if (this.hasStickyHeader) {
        !this.observer && this.observeNode(this.tableTempContainer);

        /* Almacenar la posición scroll del contenedor de filtros y los contenedores de tabla para 
        restaurarlos después, ya que "replaceChildren()" los resetea a 0 
        */
        this.lastContentScrollTopPos = this.dropdownContent.scrollTop;
        this.lastTableScrollTopPos =
          this.tableTempContainer.scrollTop || this.tableContainer.scrollTop;
        this.lastTableScrollLeftPos =
          this.tableTempContainer.scrollLeft || this.tableContainer.scrollLeft;

        /* Se modifica un atributo para que el MutationObserver se active y se haga el reemplazo de la tabla hacia
        el contenedor temporal, manteniendo también el scroll que se tenía antes del reemplazo. */
        this.tableTempContainer.style.opacity = '1'; 
      } else {
        this.dropdownContent.style.position = "absolute";
        this.disableScroll();
      }

      if (!this.tableContainer.hasAppliedEvent) {
        this.tableContainer.hasAppliedEvent = true;
        this.handleContainerPosition = () =>
          this.calculateFilterContainerXYPosition();
        window.addEventListener("resize", this.handleContainerPosition);
      }
    } else {
      this.observer && this.observer.disconnect();
      this.observer = null;

      // Al cerrar el dropdown, habilitar el scroll y revertir la tabla al contenedor original si este existe en el contenedor temporal de la tabla
      if (this.hasStickyHeader && this.tableTempContainer.children[0]) {
        /* En este caso se pone la opacidad en 0 al cerrarse la caja de filtros, solo servirá para disparar el observer
        cuando el valor se vuelva a poner en 1 al abrirse nuevamente. */
        this.tableTempContainer.style.opacity = "0";
        this.tableContainer.replaceChildren(
          this.tableTempContainer.children[0]
        );

        this.tableContainer.scrollTop = this.lastTableScrollTopPos;
        this.tableContainer.scrollLeft = this.lastTableScrollLeftPos;
      }

      this.tableContainer.hasAppliedEvent = false;
      window.removeEventListener("resize", this.handleContainerPosition);
      this.enableScroll();
    }
  },
  moveToExternalContainer() {
    Object.assign(this.dropdownContent.style, {
      top: `${this.toggleButton.getBoundingClientRect().bottom}px`,
    });

    // Se obtiene la tabla desde la última ubicación para ser reemplazada.
    const tableContainerChild = this.el.closest('.table-root').querySelector('table'); 
    this.tableTempContainer.replaceChildren(tableContainerChild);

    this.disableScroll();
    this.setCurrentHeaderToTop();

    this.dropdownContent.scrollTop = this.lastContentScrollTopPos;
    this.tableTempContainer.scrollTop = this.lastTableScrollTopPos;
    this.tableTempContainer.scrollLeft = this.lastTableScrollLeftPos;
  },

  /* En este caso, el uso de un MutationObserver en el contenedor temporal para reaccionar a cambios inmediatos
  parece ser una mejor alternativa que un "setInterval()" o "requestAnimationFrame()" para solucionar el problema de 
  "parpadeo" que se da al hacer el cambio de nodos con replaceChildren para los contenedores con encabezado "sticky".
  El problema se daba por el flujo de actualización. Sin el uso del Observer, al aplicar un filtro se disparaban 2 
  actualizaciones, una sobre el cambio del hook y otra sobre el cambio de la tabla, esta última al ser un re-render, 
  ocasionaba que el replaceChildren() se revirtiera, con lo cual se utilizaba un setInterval para checar por la última 
  actualización y ahí aplicar la función, lo cual funcionaba pero ocasionaba el efecto de "parapadeo", mostrándose la 
  caja de filtros por debajo del overflow de la tabla, desapareciendo y luego apareciendo por encima con replaceChildren().
  */
  observeNode(targetNode) {
    const callback = (mutationsList, observer) => {
      if (this.dropdownContent && !this.tableTempContainer.children[0]) {
        this.moveToExternalContainer();
      }
    };

    this.observer = new MutationObserver(callback);
    this.observer.observe(targetNode, {
      attributes: true, // Detectar cambios en atributos
      // childList: true,  // Detectar nodos hijos agregados o eliminados
      // subtree: true,    // Observar también los nodos descendientes
    });
  },
  calculateFilterContainerXYPosition() {
    const viewportWidth = window.innerWidth;
    const pastMaxWidthOffset =
      Math.max(0, viewportWidth - this.maxWidthApp) / 2; // Saca el número positivo resultante o 0 si es negativo
    const tableContainerRect = this.tableContainer.getBoundingClientRect();
    const tableCardPadding = 24;
    const rect = this.toggleButton.getBoundingClientRect();
    let rectContent = this.dropdownContent.getBoundingClientRect();

    if (this.hasStickyHeader) {
      this.dropdownContent.style.top = `${rect.bottom}px`;
      this.dropdownContent.style.left = `${rect.left}px`;
    } else {
      this.dropdownContent.style.left = `${
        Math.round(rect.left) -
        Math.round(rect.width * 2) -
        Math.round(pastMaxWidthOffset) -
        12
      }px`; // `${Math.round(rect.left) - Math.round(rect.width * 2) - 12}px`; // `${rect.left - (rect.width * 2) - (rectContent.width / 2)}px`
    }

    rectContent = this.dropdownContent.getBoundingClientRect();

    if (rectContent.right > tableContainerRect.right + tableCardPadding) {
      // viewportWidth
      if (this.hasStickyHeader) {
        this.dropdownContent.style.left = `${
          tableContainerRect.right - rectContent.width
        }px`;
      } else {
        this.dropdownContent.style.left = "auto";
        this.dropdownContent.style.right = "0px";
      }
    } else if (rectContent.left < tableContainerRect.left - tableCardPadding) {
      // 0
      this.dropdownContent.style.left = "0px";
    }
  },
  /** Deshabilita el scroll de forma global, solo habilita los pointer events a las columnas th y al contenedor,
   * esto para que cuando se abra la caja de filtros, todavía se pueda interactuar con los elementos internos,
   * hacer scroll y abrir otro filtro si se requiere sin tener que cerrar primero la caja activa
   */
  disableScroll() {
    globalScrollEvents.disable(this.limitScrollEventOnContentEvt);
    this.setPointerEvents("auto");
  },
  enableScroll() {
    globalScrollEvents.enable(this.limitScrollEventOnContentEvt);
  },
  setPointerEvents(value) {
    const toggleButtons = document.querySelectorAll(
      ".table-track-filter-content-position"
    );
    for (let index = 0; index < toggleButtons.length; index++) {
      const buttonEl = toggleButtons[index];
      buttonEl.closest("th").style.pointerEvents = value;
    }

    this.dropdownContent.style.pointerEvents = value;
  },
  /* Establece el z-index de todos los headers a 0 y el actual a 9999 para que el 
  contenedor de filtros no se corte con los headers cercanos */
  setCurrentHeaderToTop() {
    const tableHeads = this.tableRoot.querySelectorAll("thead > tr > th");
    for (let index = 0; index < tableHeads.length; index++) {
      const th = tableHeads[index];
      th.style.zIndex = 3;
    }

    if (this.dropdownContent) {
      this.dropdownContent.closest('th').style.zIndex = 4;
    }
  },
};

exports.FixedDropdown = {
  mounted() {
    this.updatePositionListener = () => {
      this.updatePosition();
    };
  },
  updated() {
    const open = this.el.dataset.dropdownState == "true";

    this.elTd = this.el.closest('td');
    this.insideTableWithStickyColumn = this.elTd && this.elTd.dataset.stickyColumn == 'true';

    if (open) {
      if (this.insideTableWithStickyColumn) {
        const { left, top, height } = this.elTd.getBoundingClientRect();
        this.elTr = this.elTd.closest('tr');

        this.elTd.style.zIndex = 2;
        this.elTd.style.position = "fixed";
        this.elTd.style.left = `${left}px`;
        this.elTd.style.top = `${top}px`;
        this.elTr.style.height = `${height}px`;
      }

      this.updatePosition();
      window.addEventListener("resize", this.updatePositionListener);
      this.disableScroll();
    } else {
      if (this.insideTableWithStickyColumn) {
        this.elTd.style.zIndex = 1;
        this.elTd.style.position = "sticky";
        this.elTd.style.left = "0px";
        this.elTd.style.top = "0px";
      }

      window.removeEventListener('resize', this.updatePositionListener);
      this.enableScroll();
    }
  },
  destroyed() {
    this.enableScroll();
    window.removeEventListener("resize", this.updatePositionListener);
  },
  /** Deshabilita el scroll de forma global, solo permitiendo la interacción con elementos
   * del contenedor dropdown y con los botones dropdown que se encuentren en la página
   */
  disableScroll() {
    globalScrollEvents.disable();
    this.setPointerEvents("auto");
  },
  enableScroll() {
    globalScrollEvents.enable();
  },
  setPointerEvents(value) {
    const dropdownButtons = document.querySelectorAll(".dropdown-btn");
    for (let index = 0; index < dropdownButtons.length; index++) {
      const buttonEl = dropdownButtons[index];
      buttonEl.style.pointerEvents = value;
    }

    this.el.nextElementSibling.style.pointerEvents = value;
  },
  updatePosition() {
    const initialPosition = this.el.dataset.position;
    const windowHeight = window.innerHeight;
    const windowWidth = window.innerWidth;
    const dropdownElement = this.el.nextElementSibling;

    const { x, y, height, left, right } = this.el.getBoundingClientRect();
    Object.assign(dropdownElement.style, {
      left: `${x}px`,
      top: `${y + height}px`,
    });

    const dropdownElementRect = dropdownElement.getBoundingClientRect();
    const offset = 24;

    if (initialPosition === "bottom-left") {
      Object.assign(dropdownElement.style, {
        left: `${right - dropdownElementRect.width}px`,
      });
    } else if (initialPosition === "bottom-right") {
      Object.assign(dropdownElement.style, {
        left: `${left}px`,
      });
    }

    if (dropdownElementRect.bottom + offset / 2 >= windowHeight) {
      Object.assign(dropdownElement.style, {
        top: `${
          dropdownElementRect.top - height - dropdownElementRect.height - offset
        }px`,
      });
    }

    if (dropdownElementRect.right >= windowWidth - offset) {
      Object.assign(dropdownElement.style, {
        left: `${windowWidth - dropdownElementRect.width - offset}px`,
      });
    } else if (dropdownElementRect.left - offset <= 0) {
      Object.assign(dropdownElement.style, {
        left: `${offset}px`,
      });
    }
  },
};

exports.DisableDraggableColumns = {
  mounted() {
    this.tableheader_drag_events = [];

    const events = [
      [
        "mouseup",
        (e) => e.currentTarget.closest("th").setAttribute("draggable", true),
      ],
      [
        "mousedown",
        (e) => e.currentTarget.closest("th").setAttribute("draggable", false),
      ],
    ];

    events.forEach((event) => {
      this.el.addEventListener(...event);
      this.tableheader_drag_events.push(event);
    });
  },
  destroyed() {
    this.tableheader_drag_events.forEach((event) => {
      this.el.removeEventListener(...event);
    });
    this.tableheader_drag_events = [];
  },
};

exports.DraggableColumns = {
  mounted() {
    this.initializeDraggableColumns();
  },
  updated() {
    /* Al actualizar, limpiar primero los eventos previos de 'tableheader_drag_events' para evitar 
    problemas de eventos repetidos al utilizar addEventListener en 'initializeDraggableColumns() */
    this.cleanupDraggableColumns();
    this.initializeDraggableColumns();
  },
  destroyed() {
    this.cleanupDraggableColumns();
  },
  initializeDraggableColumns() {
    this.tableheader_drag_events = [];

    const table = this.el;
    const headers = table.querySelectorAll("th");

    headers.forEach((header, index) => {
      if (header.style.display !== "none") {
        header.setAttribute("data-index", index);
        header.draggable = true;

        const events = [
          ["dragstart", this.handleDragStart.bind(this)],
          ["dragover", this.handleDragOver.bind(this)],
          ["dragleave", this.handleDragLeave.bind(this)],
          ["drop", this.handleDrop.bind(this)],
          ["dragend", this.handleDragEnd.bind(this)],
        ];

        events.forEach((event) => {
          header.addEventListener(...event);
        });

        this.tableheader_drag_events.push({ header, events });
      }
    });
  },
  cleanupDraggableColumns() {
    (this.tableheader_drag_events || []).forEach(({ header, events }) => {
      events.forEach((event) => {
        header.removeEventListener(...event);
      });
    });
  },
  handleDragStart(e) {
    const headerLabel = e.target.closest("th").textContent.trim();
    if (headerLabel === "Acciones") {
      e.preventDefault();
      return;
    }
    e.dataTransfer.setData("text/plain", e.target.closest("th").dataset.index);
    e.dataTransfer.effectAllowed = "move";
    e.target.closest("th").classList.add("dragging");
  },
  handleDragOver(e) {
    const headerLabel = e.target.closest("th").textContent.trim();
    if (headerLabel === "Acciones") {
      e.preventDefault();
      return;
    }
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
    e.target.closest("th").classList.add("drag-over");
  },
  handleDragLeave(e) {
    e.target.closest("th").classList.remove("drag-over");
  },
  handleDrop(e) {
    const headerLabel = e.target.closest("th").textContent.trim();
    if (headerLabel === "Acciones") {
      e.preventDefault();
      return;
    }
    e.preventDefault();

    const fromIndex = parseInt(e.dataTransfer.getData("text/plain"), 10);
    const toIndex = parseInt(e.target.closest("th").dataset.index, 10);

    if (!isNaN(fromIndex) && !isNaN(toIndex) && fromIndex !== toIndex) {
      const headers = Array.from(this.el.querySelectorAll("th"));
      const movedHeader = headers[fromIndex];
      const targetHeader = headers[toIndex];

      movedHeader.parentNode.removeChild(movedHeader);
      targetHeader.insertAdjacentElement(
        fromIndex < toIndex ? "afterend" : "beforebegin",
        movedHeader
      );

      this.pushEvent("reorder_columns", {
        from: String(fromIndex),
        to: String(toIndex),
      });

      headers.forEach((header, index) => {
        if (header.style.display !== "none") {
          header.setAttribute("data-index", index);
        }

        // Inicia bloque relacionado al hook "TableTrackFilterContentPosition"
        const tableTrackFilterContentPosition =
          header &&
          header.querySelector(".table-track-filter-content-position");
        if (tableTrackFilterContentPosition) {
          const filterButton =
            tableTrackFilterContentPosition.querySelector(
              `.table-dropdown-content-${tableTrackFilterContentPosition.id}`
            ) &&
            tableTrackFilterContentPosition.querySelector(
              `.table-dropdown-toggle-${tableTrackFilterContentPosition.id}`
            );

          /* Se simula un clic en el botón de la columna del filtro correspondiente 
          para forzar un reposicionamiento (disparando un "update" en el hook) */
          if (filterButton) {
            filterButton.click();
          }
        } // Termina bloque relacionado al hook "TableTrackFilterContentPosition"
      });
    }

    this.el.querySelectorAll("th").forEach((header) => {
      header.classList.remove("drag-over");
    });
    e.target.closest("th").classList.remove("dragging");
  },
  handleDragEnd(e) {
    e.target.closest("th").classList.remove("dragging");

    this.el.querySelectorAll("th").forEach((header) => {
      header.classList.remove("drag-over");
    });
  },
};

exports.StopPropagationHook = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      e.stopPropagation();
    });
  },
};

exports.InputMoney = {
  mounted() {
    const hiddenInput = document.querySelector(`#${this.el.id}-hidden-value`);
    
    // Formatear el input si tiene un valor inicial
    if (this.el.value.trim() !== "") {
      this.el.value = this.formatCurrency(hiddenInput.value); 
      hiddenInput.value = this.el.value.replace(/[^0-9.-]+/g, ""); 
    }

    this.focusEvent = (event) => {
      event.stopPropagation();

      hiddenInput.value = this.el.value.replace(/[^0-9.-]+/g, "");
      this.el.value = hiddenInput.value;
    }

    this.inputEvent = (event) => {
      const value = event.target.value;
      const formattedValue = this.formatCurrency(value);
      hiddenInput.value = value === "" ?  "" : formattedValue.replace(/[^0-9.-]+/g, "");
    }

    this.blurEvent = (event) => {
      event.stopPropagation();
      
      // Solo formatear el input si tiene un valor, de lo contrario se deja vacío
      if (this.el.value.trim() !== "") {
        this.el.value = this.formatCurrency(hiddenInput.value);
      }
    }

    this.el.addEventListener("focus", this.focusEvent);
    this.el.addEventListener("input", this.inputEvent);
    this.el.addEventListener("blur", this.blurEvent);
  },
  destroyed() {
    this.el.removeEventListener("focus", this.focusEvent);
    this.el.removeEventListener("input", this.inputEvent);
    this.el.removeEventListener("blur", this.blurEvent);
  },
  formatCurrency(value) {
    const numericValue = parseFloat(value) || 0;
    return new Intl.NumberFormat("es-MX", {
      style: "currency",
      currency: "MXN",
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(numericValue);
  },
};
