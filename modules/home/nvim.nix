{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.nvim;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  options.modules.home.nvim.enable = lib.mkEnableOption "Neovim IDE complet";

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        # ── Thème ─────────────────────────────────────────────────
        catppuccin-nvim

        # ── Interface ─────────────────────────────────────────────
        nvim-tree-lua
        nvim-web-devicons
        lualine-nvim
        bufferline-nvim

        # ── Syntaxe ───────────────────────────────────────────────
        (nvim-treesitter.withPlugins (p: with p; [
          bash
          c
          css
          dockerfile
          go
          html
          java
          javascript
          json
          lua
          markdown
          nix
          python
          rust
          toml
          typescript
          yaml
        ]))

        # ── Autocomplétion (blink.cmp) ────────────────────────────
        blink-cmp
        windsurf-nvim

        # ── Snippets ──────────────────────────────────────────────
        luasnip
        friendly-snippets

        # ── Fuzzy finder ──────────────────────────────────────────
        telescope-nvim
        telescope-fzf-native-nvim
        plenary-nvim

        # ── Git ───────────────────────────────────────────────────
        gitsigns-nvim

        # ── Qualité de vie ────────────────────────────────────────
        which-key-nvim
        nvim-autopairs
        comment-nvim
        indent-blankline-nvim
        nvim-colorizer-lua
      ];

      extraPackages = with pkgs; [
        lua-language-server
        nil               # Nix LSP
        pyright           # Python LSP
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON/ESLint
        rust-analyzer
        gopls
      ];

      initLua = ''
        -- ── Options globales ──────────────────────────────────────────
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.signcolumn = "yes"
        vim.opt.cursorline = true
        vim.opt.wrap = false
        vim.opt.scrolloff = 8
        vim.opt.sidescrolloff = 8

        -- Indentation
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.smartindent = true

        -- Recherche
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.hlsearch = true
        vim.opt.incsearch = true

        -- Apparence
        vim.opt.termguicolors = true
        vim.opt.showmode = false
        vim.opt.splitbelow = true
        vim.opt.splitright = true

        -- Fichiers
        vim.opt.undofile = true
        vim.opt.swapfile = false
        vim.opt.backup = false
        vim.opt.updatetime = 250

        -- Supprimer les messages de démarrage
        vim.opt.shortmess:append("sIcC")

        -- Leader
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        -- ── Thème Catppuccin ──────────────────────────────────────────
        require("catppuccin").setup({
          flavour = "${themeCfg.flavor}",
          integrations = {
            nvim_tree = true,
            treesitter = true,
            telescope = { enabled = true },
            gitsigns = true,
            which_key = true,
            indent_blankline = { enabled = true },
            bufferline = true,
            lsp_trouble = false,
          },
        })
        vim.cmd.colorscheme("catppuccin")

        -- ── Lualine ───────────────────────────────────────────────────
        require("lualine").setup({
          options = {
            theme = "catppuccin",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
          },
        })

        -- ── Bufferline ────────────────────────────────────────────────
        require("bufferline").setup({
          options = {
            themable = true,
          },
        })

        -- ── nvim-tree ─────────────────────────────────────────────────
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        require("nvim-tree").setup({
          view = { width = 30 },
          renderer = {
            group_empty = true,
            icons = {
              show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
              },
            },
          },
          filters = { dotfiles = false },
          git = { enable = true },
        })

        -- ── blink.cmp ─────────────────────────────────────────────────
        require("blink.cmp").setup({
          keymap = { preset = "super-tab" },
          appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
          },
          sources = {
            default = { "lsp", "path", "snippets", "buffer", "codeium" },
            providers = {
              codeium = { name = "Codeium", module = "codeium.blink", async = true },
            },
          },
          snippets = { preset = "luasnip" },
          completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
          },
        })


        -- ── Windsurf ──────────────────────────────────────────────────
        require("codeium").setup({
          enable_cmp_source = false,
        })


        -- ── LSP (nvim 0.11 API) ───────────────────────────────────────
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        vim.lsp.config("*", { capabilities = capabilities })

        vim.lsp.config("lua_ls", {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        })

        vim.lsp.enable({
          "lua_ls",
          "nil_ls",
          "pyright",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "rust_analyzer",
          "gopls",
        })

        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })

        -- ── Telescope ─────────────────────────────────────────────────
        require("telescope").setup({
          defaults = {
            file_ignore_patterns = { "node_modules", ".git/" },
          },
        })
        require("telescope").load_extension("fzf")

        -- ── Gitsigns ──────────────────────────────────────────────────
        require("gitsigns").setup()

        -- ── Autopairs ─────────────────────────────────────────────────
        require("nvim-autopairs").setup()

        -- ── Comment ───────────────────────────────────────────────────
        require("Comment").setup()

        -- ── Indent blankline ──────────────────────────────────────────
        require("ibl").setup({
          indent = { char = "│" },
          scope = { enabled = true },
        })

        -- ── Colorizer ─────────────────────────────────────────────────
        require("colorizer").setup()

        -- ── Which-key ─────────────────────────────────────────────────
        local wk = require("which-key")
        wk.setup()
        wk.add({
          { "<leader>f",  group = "Fichiers" },
          { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Trouver fichier" },
          { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Grep" },
          { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
          { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Aide" },

          { "<leader>e",  "<cmd>NvimTreeToggle<cr>",        desc = "Explorateur" },

          { "<leader>g",  group = "Git" },
          { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>",   desc = "Stage hunk" },
          { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>",   desc = "Reset hunk" },
          { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
          { "<leader>gb", "<cmd>Gitsigns blame_line<cr>",   desc = "Blame" },

          { "<leader>l",  group = "LSP" },
          { "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>",     desc = "Définition" },
          { "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>",     desc = "Références" },
          { "<leader>ln", "<cmd>lua vim.lsp.buf.rename()<cr>",         desc = "Renommer" },
          { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",    desc = "Actions" },
          { "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>",         desc = "Formater" },
          { "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>",          desc = "Hover" },
          { "<leader>le", "<cmd>lua vim.diagnostic.open_float()<cr>",  desc = "Diagnostics" },

          { "<leader>b",  group = "Buffers" },
          { "<leader>bn", "<cmd>bnext<cr>",                desc = "Suivant" },
          { "<leader>bp", "<cmd>bprevious<cr>",            desc = "Précédent" },
          { "<leader>bd", "<cmd>bdelete<cr>",              desc = "Fermer" },
        })

        -- ── Autocommands ───────────────────────────────────────────────
        local augroup = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

        -- Highlight personnalisé pour le yank (lié au thème)
        vim.api.nvim_set_hl(0, "YankHighlight", { link = "Visual" })

        -- Treesitter : activation + fallback indent
        vim.api.nvim_create_autocmd("FileType", {
          group = augroup,
          desc = "Enable Treesitter or fallback indent",
          callback = function(args)
            local ok = pcall(vim.treesitter.start, args.buf)
            if not ok then
              vim.bo[args.buf].indentexpr = "nvim_treesitter#indentexpr()"
            end
          end,
        })

        -- Highlight bref lors d’un yank
        vim.api.nvim_create_autocmd("TextYankPost", {
          group = augroup,
          desc = "Highlight on yank",
          callback = function()
            vim.highlight.on_yank({
              higroup = "YankHighlight",
              timeout = 150,
            })
          end,
        })

        -- ── Keymaps divers ────────────────────────────────────────────
        local map = vim.keymap.set
        map("n", "<Esc>", "<cmd>nohlsearch<cr>")
        map("n", "K", vim.lsp.buf.hover)
        map("n", "[d", vim.diagnostic.goto_prev)
        map("n", "]d", vim.diagnostic.goto_next)
        map("n", "<C-h>", "<C-w>h")
        map("n", "<C-j>", "<C-w>j")
        map("n", "<C-k>", "<C-w>k")
        map("n", "<C-l>", "<C-w>l")
      '';
    };
  };
}
