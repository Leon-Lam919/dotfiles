-- COC.nvim configuration
return {
  {
    'neoclide/coc.nvim',
    branch = 'release',
    build = 'yarn install --frozen-lockfile && yarn build',
    config = function()
      vim.g.coc_global_extensions = {
        'coc-json',
        'coc-tsserver',
      }
    end,
  },
}
