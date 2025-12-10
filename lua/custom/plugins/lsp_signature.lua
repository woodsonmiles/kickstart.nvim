-- lua/plugins/lsp_signature.lua
return {
  'ray-x/lsp_signature.nvim',
  event = 'VeryLazy', -- load after startup
  opts = {
    -- UI and behavior
    hint_enable = false, -- disable inline hints; keep only popup
    floating_window = true, -- use floating window for signatures
    floating_window_above_cur_line = true,
    fix_pos = true, -- keep the popup at the same position
    transparency = 0, -- 0-100; 0 = opaque
    handler_opts = { border = 'rounded' }, -- 'single', 'double', 'rounded', 'solid'
    toggle_key = '<C-k>', -- toggle signature popup
    -- Trigger behavior
    auto_close_after = nil, -- keep open until you move/esc or toggle
    always_trigger = false, -- only trigger when LSP says so
    zindex = 50, -- keep above other UI
    -- Optional: parameter highlighting colors (linked to your colorscheme)
    -- You can tweak these highlights in your theme if needed.
    -- hint_prefix can add a small icon if you enable hints.
  },
  config = function(_, opts)
    local sig = require 'lsp_signature'
    sig.setup(opts)

    -- If you want it to attach only when an LSP attaches (safer in multi-LSP setups):
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.signatureHelpProvider then
          sig.on_attach(opts, args.buf)
        end
      end,
    })
  end,
}
