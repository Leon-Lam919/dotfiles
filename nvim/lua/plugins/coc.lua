-- COC.nvim configuration
return {
  {
    'neoclide/coc.nvim',
    branch = 'release',
    config = function()
      vim.g.coc_global_extensions = {
        'coc-json',
        'coc-tsserver',
      }
    end,
  },
}
