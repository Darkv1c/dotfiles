return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "stacks",      size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "watches",     size = 0.25 },
              { id = "scopes",      size = 0.25 },
            },
            size = 80,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
        },
      })
      dapui.setup = function() end -- prevent re-init

      -- Show REPL output when debug session ends
      dap.listeners.after.event_terminated["dapui"] = function()
        vim.schedule(function()
          dap.repl.open({ height = 12 })
          vim.notify("Debug session terminated", vim.log.levels.INFO)
        end)
      end
      dap.listeners.after.event_exited["dapui"] = function()
        vim.schedule(function()
          dap.repl.open({ height = 12 })
          vim.notify("Debug session exited", vim.log.levels.INFO)
        end)
      end

      -- Auto-open REPL on exception break
      dap.listeners.after.event_stopped["dapui_exception"] = function(_, body)
        if body.reason == "exception" then
          vim.schedule(function()
            dapui.float_element("repl")
            vim.notify("Debug exception: " .. (body.text or "unknown"), vim.log.levels.WARN)
          end)
        end
      end

      -- Auto-open REPL on stderr output (bash errors)
      dap.listeners.after.event_output["bash_stderr"] = function(_, body)
        if body.category == "stderr" and body.output and body.output ~= "" then
          -- Ignore known bashdb init errors (no TTY in debugConsole mode)
          if body.output:match("/dev/stdin") then return end
          vim.schedule(function()
            dapui.float_element("repl")
          end)
        end
      end

      -- Bash adapter (bash-debug-adapter from Mason)
      dap.adapters.bash = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/bash-debug-adapter",
        args = {},
      }

      local mason_path = vim.fn.stdpath("data") .. "/mason"
      local bashdb_dir = mason_path .. "/packages/bash-debug-adapter/extension/bashdb_dir"

      dap.configurations.sh = {
        {
          type = "bash",
          request = "launch",
          name = "Run current file",
          program = "${file}",
          args = vim.fn.json_decode("[]"),
          argsString = "",
          cwd = "${workspaceFolder}",
          pathBash = "/usr/bin/bash",
          pathBashdb = bashdb_dir .. "/bashdb",
          pathBashdbLib = bashdb_dir .. "/",
          pathCat = "/usr/bin/cat",
          pathMkfifo = "/usr/bin/mkfifo",
          pathPkill = "/usr/bin/pkill",
          env = vim.empty_dict(),
          terminalKind = "debugConsole",
        },
      }
      -- Same config for .bash extension
      dap.configurations.bash = dap.configurations.sh

      -- DAP debugger keymaps
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Breakpoint with condition" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue / Start" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
      vim.keymap.set({ "n", "v" }, "<leader>dh", dapui.eval, { desc = "Evaluate expression under cursor" })

      -- DAP-UI manual windows
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle all DAP-UI panels" })
      vim.keymap.set("n", "<leader>dr", function() dapui.float_element("repl") end, { desc = "Toggle REPL float" })
      vim.keymap.set("n", "<leader>ds", function() dapui.float_element("stacks") end, { desc = "Open stacks (float)" })
      vim.keymap.set("n", "<leader>dw", function() dapui.float_element("watches") end, { desc = "Open watches (float)" })
      vim.keymap.set("n", "<leader>dS", function() dapui.float_element("scopes") end, { desc = "Open scopes (float)" })
      vim.keymap.set("n", "<leader>dL", function() dapui.float_element("breakpoints") end, { desc = "Open breakpoints (float)" })
    end,
  },
}
