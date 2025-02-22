window.addEventListener("phx:disabled-by-id", (event) => {
  const el = document.getElementById(event.detail.id)
  if (el) {
    el.disabled = event.detail.disabled
  }
});

window.addEventListener("phx:trigger-event-by-id", (event) => {
  const el = document.getElementById(event.detail.id)
  el && el[event.detail.event_type]()
  // el.selectionStart = el.selectionEnd = el.value.length;
});

window.addEventListener("phx:reset-input-by-id", (event) => {
  const el = document.getElementById(event.detail.id)
  if (el) {
    el.value = ""
  }
});