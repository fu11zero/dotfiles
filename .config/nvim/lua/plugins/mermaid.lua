require("diagram").setup({
  integrations = {
    require("diagram.integrations.markdown"),
    require("diagram.integrations.neorg"),
  },
  renderer_options = {
    mermaid = {
      background = nil, -- nil | "transparent" | "white" | "#hex"
      theme = nil, -- nil | "default" | "dark" | "forest" | "neutral"
      scale = 10, -- nil | 1 (default) | 2  | 3 | ...
      width = 2048, -- nil | 800 | 400 | ...
      height = 2048, -- nil | 600 | 300 | ...
    },
    plantuml = {
      charset = "utf-8",
    },
    d2 = {
      theme_id = 1,
    },
    gnuplot = {
      theme = "dark",
      -- size = "800,600",
    },
    cli_args = {
      "--width", "2048",
      "--height", "2048"
    },
  },
})
