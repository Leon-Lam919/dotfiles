-- Editor enhancement plugins
return {
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- File tree
  { 'preservim/nerdtree' },

  -- Terminal
  { 'akinsho/toggleterm.nvim', version = '*', config = true },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
      -- Integration with nvim-cmp
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  -- Icons
  'ryanoasis/vim-devicons',
}
