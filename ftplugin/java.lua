local home = os.getenv("HOME")
local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local java21_path = "/usr/lib/jvm/java-21-openjdk-amd64"

local workspace_path = home .. "/.local/share/eclipse/" .. workspace_dir

-- See `:help vim.lsp.start` for an overview of the supported `config` options.
local config = {
  name = "jdtls",

  -- `cmd` defines the executable to launch eclipse.jdt.ls.
  -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
  --
  -- As alternative you could also avoid the `jdtls` wrapper and launch
  -- eclipse.jdt.ls via the `java` executable
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  --
  cmd = {
    java21_path .. "/bin/java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    "/opt/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250519-0528.jar", -- launcher jar is wrapped in this script
    "-configuration",
    "/opt/jdtls/config_linux",
    "-data",
    workspace_path,
  },

  -- `root_dir` must point to the root of your project.
  -- See `:help vim.fs.root`
  root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw" }),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      home = "/usr/lib/jvm/java-8-openjdk-amd64", -- use Java 8 for project
      configuration = {
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = "/usr/lib/jvm/java-1.8.0-amazon-corretto",
          },
          {
            name = "JavaSE-21",
            path = java21_path,
          },
        },
      },
    },
  },

  -- This sets the `initializationOptions` sent to the language server
  -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
  -- you'll need to set the `bundles`
  --
  -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {},
  },
}
require("jdtls").start_or_attach(config)

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Number of spaces for each indentation
vim.opt.tabstop = 4 -- Number of spaces a <Tab> counts for
vim.opt.softtabstop = 4 -- Number of spaces inserted/deleted with <Tab>/<BS>
vim.keymap.set("n", "A-o", "<cmd>lua require('jdtls').organize_imports()<CR>", { desc = "Organize Import for Java" })
