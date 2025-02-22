// ---------------------------------------
// CHANNEL PARA CAMBIO DE TEMA DE LA APP
// ---------------------------------------
export function themeChangeChannel(socket) {
  // Unirse al canal "theme:change"
  const themeChannel = socket.channel("theme:change", {})
  themeChannel.join()
    // .receive("ok", resp => { console.log("Conectado al canal theme:change", resp) })
    // .receive("error", resp => { console.warn("No se pudo conectar al canal theme:change", resp) })

  // Escuchar el evento de actualización de tema desde el servidor
  themeChannel.on("theme_change_from_server", payload => {
    // console.log(payload);

    // Actualizar el atributo en root.html.heex con el nuevo tema de color
    document.documentElement.setAttribute("data-theme", payload.new_theme)

    // Actualizar todas las instancias de logo (custom component <.app_logo>) en su atributo src
    document.querySelectorAll("[data-logo]").forEach(logo => {
      logo.setAttribute("src", `/images/${payload.new_theme}_logo.svg`)
    })
  })

  // Enviar mensaje de regreso al servidor (si se requiere)
  // themeChannel.push("theme_change_from_client", {new_theme: "tema cambiado!"})
}