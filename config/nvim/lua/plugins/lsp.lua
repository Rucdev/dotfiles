-- LSP サーバーのバイナリは mason ではなく Nix (home/neovim.nix) で管理する。
-- nvim-lspconfig はサーバーごとのデフォルト設定 (cmd / filetypes / root_markers) を
-- 提供するためだけに使い、cmd は PATH 上のバイナリを解決する。
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("gr", vim.lsp.buf.references, "Go to References")
          map("gI", vim.lsp.buf.implementation, "Go to Implementation")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
          map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
          map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("<leader>e", vim.diagnostic.open_float, "Show Diagnostic")
        end,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- 全サーバー共通の設定
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- 有効化するサーバー一覧。key は nvim-lspconfig のサーバー名、
      -- value は追加設定 (不要なら {})。
      -- サーバーを増やすときは home/neovim.nix にもパッケージを追加する。
      --
      -- vim.lsp.enable() はプロセスを起動するのではなく、各サーバーの filetypes に
      -- 対する FileType autocmd を登録するだけ。該当ファイルを開いたときだけ起動する。
      local servers = {
        gopls = {},
        rust_analyzer = {},
        ts_ls = {},
        ty = {},
        astro = {
          -- lspconfig のデフォルトはプロジェクトの node_modules/typescript しか探さない。
          -- 見つからなければ Nix で入れた typescript (tsserver の隣) にフォールバックする。
          before_init = function(_, config)
            local ts = config.init_options and config.init_options.typescript
            if ts and not ts.tsdk then
              local tsdk = require("lspconfig.util").get_typescript_server_path(config.root_dir)
              if tsdk == "" then
                local tsserver = vim.fn.exepath("tsserver")
                if tsserver ~= "" then
                  -- Nix の bin/tsserver はラッパースクリプトなので realpath は
                  -- <store>/bin/tsserver。npm の標準レイアウトに従い
                  -- <store>/lib/node_modules/typescript/lib を tsdk とする。
                  local prefix = vim.fs.dirname(vim.fs.dirname(vim.uv.fs_realpath(tsserver)))
                  tsdk = vim.fs.joinpath(prefix, "lib", "node_modules", "typescript", "lib")
                end
              end
              ts.tsdk = tsdk
            end
          end,
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        nil_ls = {
          settings = {
            ["nil"] = {
              -- flake inputs を自動で fetch し、起動時の対話プロンプトを出さない
              nix = { flake = { autoArchive = true } },
            },
          },
        },
      }

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
        -- バイナリが PATH に無いサーバーは有効化せず警告する
        -- (Nix 側に入れ忘れたときに attach 失敗のエラーで埋まらないように)
        local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
        if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0 then
          vim.notify(("LSP '%s': '%s' が PATH にありません (home/neovim.nix を確認)"):format(server, cmd[1]),
            vim.log.levels.WARN)
        else
          vim.lsp.enable(server)
        end
      end
    end,
  },
}
