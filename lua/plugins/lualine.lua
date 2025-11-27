return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Defer to the config module; use pcall to avoid throwing if not installed yet
    end,
  },
}
