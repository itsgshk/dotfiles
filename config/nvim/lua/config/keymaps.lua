local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", function()
  vim.cmd("stopinsert")
  vim.cmd("write")
end, { desc = "Save file" })

map("n", "<C-p>", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })

map("n", "<C-S-f>", function()
  require("telescope.builtin").live_grep()
end, { desc = "Search in project" })

map("n", "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Debug: Start/Continue" })

map("n", "<S-F5>", function()
  require("dap").terminate()
end, { desc = "Debug: Stop" })

map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

map("n", "<S-F11>", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

map("n", "<C-F5>", function()
  vim.cmd("write")
  vim.cmd("split term://python3 %")
end, { desc = "Run file (no debug)" })
