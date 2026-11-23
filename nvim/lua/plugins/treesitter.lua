-- Treesitter configuration for syntax highlighting
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- main branch doesn't support lazy-loading
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'

      ts.install {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'python',
        'javascript',
        'java',
        'typescript',
        'css',
        'json',
        'yaml',
        'toml',
      }

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end

          if pcall(vim.treesitter.start, args.buf, lang) then
            -- highlighting started; add treesitter indent (skip ruby)
            if lang ~= 'ruby' then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          elseif vim.tbl_contains(ts.get_available(), lang) then
            -- replacement for auto_install: fetch the parser for next time
            ts.install(lang)
          end
        end,
      })
    end,
  },
}
