return {
  -- Avante.nvim brings Cursor-like agentic/inline AI into Neovim
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- never pin to "*" — Avante moves fast
  build = function()
    if vim.fn.has 'win32' == 1 then
      return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    else
      return 'make'
    end
  end,

  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    -- Optional UI niceties
    { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'markdown', 'Avante' }, opts = { file_types = { 'markdown', 'Avante' } } },
  },

  opts = function()
    -- Helper to read env vars
    local getenv = function(name)
      return vim.env[name]
    end

    -- -------- Providers (FREE tiers only) --------
    -- Avante supports OpenAI-compatible endpoints and separate provider modules.
    -- See provider architecture/modes: DeepWiki doc.

    local providers = {
      -- 1) Google Gemini (AI Studio) — FREE tier (rate-limited)
      -- Avante speaks OpenAI-style payloads; Gemini offers OpenAI-compatible gateway in some SDKs.
      -- If your endpoint differs, update the URL below to your gateway that accepts OpenAI-style chat.
      gemini_free = {
        endpoint = 'https://generativelanguage.googleapis.com/v1beta/openai', -- OpenAI-compatible gateway
        model = 'gemini-1.5-flash', -- free-friendly model; cheap & fast
        api_key_name = 'GEMINI_API_KEY',
        timeout = 30000,
        temperature = 0,
        max_tokens = 2048,
        disable_tools = true, -- legacy (non-agentic) by default → fewer tokens
      },

      -- 2) Cohere Command (Trial) — FREE Trial key (rate-limited)
      cohere_trial = {
        endpoint = 'https://api.cohere.com/v1', -- Cohere Chat v2 is supported via compatible wrappers
        model = 'command-r-plus', -- long-context, good for RAG; trial is free (dev use only)
        api_key_name = 'COHERE_API_KEY',
        timeout = 30000,
        temperature = 0,
        max_tokens = 2048,
        disable_tools = true, -- legacy mode; you can enable agentic later per task
        -- Some deployments may need an OpenAI-compatible proxy for Avante;
        -- if so, point endpoint to that proxy and use model "cohere:command-r-plus".
      },

      -- 3) OpenRouter — FREE models via unified API (OpenAI-compatible)
      -- Pick a known free model from the catalog; examples change frequently.
      -- See OpenRouter docs/catalog for up-to-date free models.
      openrouter_free = {
        endpoint = getenv 'OPENROUTER_BASE_URL' or 'https://openrouter.ai/api/v1',
        -- Example free models (as of late 2025, often listed as ":free")
        -- You should replace this with a currently-free model ID from the catalog.
        model = 'meta-llama/llama-4-maverick:free',
        api_key_name = 'OPENROUTER_API_KEY',
        timeout = 30000,
        temperature = 0,
        max_tokens = 2048,
        disable_tools = true,
        -- OpenRouter expects "HTTP-Referer" and "X-Title" headers optionally; Avante will use endpoint+key.
      },
    }

    -- Default provider: start cheap and non-agentic
    local default_provider = 'gemini_free'

    return {
      provider = default_provider,
      mode = 'legacy', -- "agentic" | "legacy"  → legacy uses no tools; cheaper & predictable.
      providers = providers,
    }
  end,

  -- Optional: quick key to cycle providers when a free tier hits caps
  keys = {
    {
      '<leader>ap',
      function()
        local cfg = require 'avante.config'
        local order = { 'gemini_free', 'cohere_trial', 'openrouter_free' }
        local cur = cfg.get().provider
        local idx = 1
        for i, name in ipairs(order) do
          if name == cur then
            idx = i
          end
        end
        local next_name = order[(idx % #order) + 1]
        cfg.set { provider = next_name }
        vim.notify(('Avante provider → %s'):format(next_name), vim.log.levels.INFO)
      end,
      desc = 'Avante: switch free provider',
    },
  },
}
