-- LSP Configurationlsp
return {
  -- Lazydev for Lua LSP
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  -- Main LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic signs with higher priority than gitsigns
      vim.diagnostic.config {
        signs = { priority = 20 }, -- default is 10
        virtual_text = true,
        underline = true,
        severity_sort = true,
      }

      for type, icon in pairs { Error = 'E', Warn = 'W', Hint = 'H', Info = 'I' } do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
      end
      -- Show diagnostics in a floating window when you hover
      vim.o.updatetime = 250 -- make CursorHold trigger faster

      vim.api.nvim_create_autocmd('CursorHold', {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
          }
          vim.diagnostic.open_float(nil, opts)
        end,
      })

      -- Define on_attach once
      local on_attach = function(client, bufnr)
        -- Example: show diagnostics in a floating window on CursorHold
        vim.o.updatetime = 250
        vim.api.nvim_create_autocmd('CursorHold', {
          buffer = bufnr,
          callback = function()
            vim.diagnostic.open_float(nil, { focusable = false })
          end,
        })

        -- Example: keymaps for LSP
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        clangd = {
          on_attach = on_attach,
          cmd = { 'clangd' },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
        },
        gopls = {},
        pyright = {},
        html = {
          settings = {
            html = {
              format = {
                enable = true,
                wrapLineLength = 120,
                wrapAttributes = 'auto',
              },
              hover = {
                documentation = true,
                references = true,
              },
            },
          },
        },
        rust_analyzer = {},
        jdtls = {
          settings = {
            java = {
              configuration = {
                runtimes = {
                  {
                    name = 'JavaSE-18',
                    path = 'C:\\Program Files\\Java\\jdk-18.0.2.1',
                  },
                },
              },
              completion = {
                importOrder = {
                  'java',
                  'javax',
                  'com',
                  'org',
                },
                maxResults = 20,
              },
              format = {
                enabled = true,
                settings = {
                  url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
                  profile = 'GoogleStyle',
                },
              },
              imports = {
                gradle = { enabled = true },
                maven = { enabled = true },
                exclusions = {
                  '**/node_modules/**',
                  '**/.git/**',
                },
              },
              codeGeneration = {
                toString = {
                  template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                },
                hashCodeEquals = {
                  useJava7Objects = true,
                },
                useBlocks = true,
              },
              diagnostics = {
                disabled = {},
                severity = {
                  typeCheckValidation = 'automatic',
                },
              },
            },
          },
          capabilities = {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = true,
                },
              },
            },
          },
        },
        ts_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        marksman = {
          cmd = { vim.fn.exepath 'marksman' },
          filetypes = { 'markdown', 'markdown.mdx' },
          root_dir = require('lspconfig.util').root_pattern('.git', 'marksman.toml', '.'),
          single_file_support = true,
          settings = {
            marksman = {},
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'jdtls',
        'java-debug-adapter',
        'java-test',
        'lombok-lombok',
        'lemminx',
        'marksman',
      })

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }
      vim.list_extend(ensure_installed, { 'html' })

      servers.html = {
        settings = {
          html = {
            format = {
              enable = true,
              wrapLineLength = 120,
              wrapAttributes = 'auto',
            },
          },
        },
      }
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local lspconfig = require 'lspconfig'

      lspconfig.html.setup {
        capabilities = capabilities,
        settings = { html = { format = { enable = true } } },
      }

      require('mason-lspconfig').setup {
        handlers = {
          jdtls = function()
            require('lspconfig').jdtls.setup {
              settings = servers.jdtls.settings,
              capabilities = vim.tbl_deep_extend('force', capabilities, servers.jdtls.capabilities or {}),
              root_dir = function(fname)
                return require('lspconfig.util').root_pattern('pom.xml', 'build.gradle', '.git')(fname) or vim.fn.getcwd()
              end,
              on_attach = function(client, bufnr)
                local map = function(keys, func, desc)
                  vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
                end

                map('<leader>jo', ':lua require("jdtls").organize_imports()<CR>', 'Organize Imports')
                map('<leader>jt', ':lua require("jdtls").test_class()<CR>', 'Test Class')
                map('<leader>jn', ':lua require("jdtls").test_nearest_method()<CR>', 'Test Nearest Method')
              end,
            }
          end,
        },
      }
      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
