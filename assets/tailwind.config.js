// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/lynxweb_web.ex",
    "../lib/lynxweb_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        "neutral-50": "rgb(var(--color-neutral-50))",
        "neutral-100": "rgb(var(--color-neutral-100))",
        "neutral-200": "rgb(var(--color-neutral-200))",
        "neutral-300": "rgb(var(--color-neutral-300))",
        "neutral-400": "rgb(var(--color-neutral-400))",
        "neutral-500": "rgb(var(--color-neutral-500))",
        "neutral-600": "rgb(var(--color-neutral-600))",
        "neutral-700": "rgb(var(--color-neutral-700))",
        "neutral-800": "rgb(var(--color-neutral-800))",
        "neutral-900": "rgb(var(--color-neutral-900))",
        'green-light': '#81c784', // Definir el color personalizado,
        "primary-subtle-light": "rgb(var(--color-primary-50))",
        "primary-subtle":       "rgb(var(--color-primary-100))",
        "primary-mid-light":    "rgb(var(--color-primary-200))",
        "primary-light":        "rgb(var(--color-primary-300))",
        "primary":              "rgb(var(--color-primary-500))",
        "primary-dark":         "rgb(var(--color-primary-700))",
        "primary-contrast":     "rgb(var(--color-primary-contrast) / <alpha-value>)",

        "card": "rgb(var(--color-card) / <alpha-value>)",
        "app":  "rgb(var(--color-app) / <alpha-value>)", 
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}
