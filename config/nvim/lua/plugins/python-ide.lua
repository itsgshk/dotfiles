return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { width = 30, position = "left" },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
            vim.cmd("Neotree show")
          end
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    opts = function()
      require("dap-python").setup("python3")
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.4 },
            { id = "breakpoints", size = 0.2 },
            { id = "stacks", size = 0.2 },
            { id = "watches", size = 0.2 },
          },
          position = "right",
          size = 40,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 10,
        },
      },
    },
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },

  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "horizontal",
      size = 15,
    },
  },
}
