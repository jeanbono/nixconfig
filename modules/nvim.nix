{ pkgs, lib, config, ... }:

let
  cfg = config.modules.nvim;
in
{
  options.modules.nvim.enable = lib.mkEnableOption "Neovim IDE complet";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (user:
      { nixosConfig, ... }:
      let
        themeCfg = nixosConfig.modules.theme.catppuccin;
      in
      {
        programs.nixvim = {
          enable = true;
          nixpkgs.source = pkgs.path;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          withRuby = false;
          withPython3 = false;

          globals = {
            mapleader = " ";
            maplocalleader = " ";
            loaded_netrw = 1;
            loaded_netrwPlugin = 1;
          };

          opts = {
            number = true;
            relativenumber = true;
            signcolumn = "yes";
            cursorline = true;
            wrap = false;
            scrolloff = 8;
            sidescrolloff = 8;
            tabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            smartindent = true;
            ignorecase = true;
            smartcase = true;
            hlsearch = true;
            incsearch = true;
            termguicolors = true;
            showmode = false;
            splitbelow = true;
            splitright = true;
            undofile = true;
            swapfile = false;
            backup = false;
            updatetime = 250;
          };

          colorschemes.catppuccin = {
            enable = true;
            settings = {
              flavour = themeCfg.flavor;
              integrations = {
                nvim_tree = true;
                treesitter = true;
                telescope.enabled = true;
                gitsigns = true;
                which_key = true;
                indent_blankline.enabled = true;
                bufferline = true;
                lsp_trouble = false;
              };
            };
          };

          plugins = {
            web-devicons.enable = true;

            lualine = {
              enable = true;
              settings.options = {
                theme = "auto";
                component_separators = { left = ""; right = ""; };
                section_separators = { left = ""; right = ""; };
              };
            };

            bufferline = {
              enable = true;
              settings.options.themable = true;
            };

            nvim-tree = {
              enable = true;
              settings = {
                view.width = 30;
                renderer = {
                  group_empty = true;
                  icons.show = {
                    file = true;
                    folder = true;
                    folder_arrow = true;
                    git = true;
                  };
                };
                filters.dotfiles = false;
                git.enable = true;
              };
            };

            treesitter = {
              enable = true;
              grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                bash c css dockerfile go html java javascript
                json lua markdown nix python rust toml typescript yaml
              ];
            };

            luasnip = {
              enable = true;
              fromVscode = [ { } ];
            };

            blink-cmp = {
              enable = true;
              settings = {
                keymap.preset = "super-tab";
                appearance = {
                  use_nvim_cmp_as_default = false;
                  nerd_font_variant = "mono";
                };
                sources.default = [ "lsp" "path" "snippets" "buffer" ];
                snippets.preset = "luasnip";
                completion.documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 200;
                };
              };
            };

            telescope = {
              enable = true;
              settings.defaults.file_ignore_patterns = [ "node_modules" ".git/" ];
              extensions.fzf-native.enable = true;
            };

            gitsigns.enable = true;

            which-key = {
              enable = true;
              settings.spec = [
                { __unkeyed-1 = "<leader>f"; group = "Fichiers"; }
                { __unkeyed-1 = "<leader>ff"; __unkeyed-2 = "<cmd>Telescope find_files<cr>"; desc = "Trouver fichier"; }
                { __unkeyed-1 = "<leader>fg"; __unkeyed-2 = "<cmd>Telescope live_grep<cr>"; desc = "Grep"; }
                { __unkeyed-1 = "<leader>fb"; __unkeyed-2 = "<cmd>Telescope buffers<cr>"; desc = "Buffers"; }
                { __unkeyed-1 = "<leader>fh"; __unkeyed-2 = "<cmd>Telescope help_tags<cr>"; desc = "Aide"; }
                { __unkeyed-1 = "<leader>e"; __unkeyed-2 = "<cmd>NvimTreeToggle<cr>"; desc = "Explorateur"; }
                { __unkeyed-1 = "<leader>g"; group = "Git"; }
                { __unkeyed-1 = "<leader>gs"; __unkeyed-2 = "<cmd>Gitsigns stage_hunk<cr>"; desc = "Stage hunk"; }
                { __unkeyed-1 = "<leader>gr"; __unkeyed-2 = "<cmd>Gitsigns reset_hunk<cr>"; desc = "Reset hunk"; }
                { __unkeyed-1 = "<leader>gp"; __unkeyed-2 = "<cmd>Gitsigns preview_hunk<cr>"; desc = "Preview hunk"; }
                { __unkeyed-1 = "<leader>gb"; __unkeyed-2 = "<cmd>Gitsigns blame_line<cr>"; desc = "Blame"; }
                { __unkeyed-1 = "<leader>l"; group = "LSP"; }
                { __unkeyed-1 = "<leader>ld"; __unkeyed-2 = "<cmd>lua vim.lsp.buf.definition()<cr>"; desc = "Définition"; }
                { __unkeyed-1 = "<leader>lr"; __unkeyed-2 = "<cmd>lua vim.lsp.buf.references()<cr>"; desc = "Références"; }
                { __unkeyed-1 = "<leader>ln"; __unkeyed-2 = "<cmd>lua vim.lsp.buf.rename()<cr>"; desc = "Renommer"; }
                { __unkeyed-1 = "<leader>la"; __unkeyed-2 = "<cmd>lua vim.lsp.buf.code_action()<cr>"; desc = "Actions"; }
                { __unkeyed-1 = "<leader>lf"; __unkeyed-2 = "<cmd>lua vim.lsp.buf.format()<cr>"; desc = "Formater"; }
                { __unkeyed-1 = "<leader>lh"; __unkeyed-2 = "<cmd>lua vim.lsp.buf.hover()<cr>"; desc = "Hover"; }
                { __unkeyed-1 = "<leader>le"; __unkeyed-2 = "<cmd>lua vim.diagnostic.open_float()<cr>"; desc = "Diagnostics"; }
                { __unkeyed-1 = "<leader>b"; group = "Buffers"; }
                { __unkeyed-1 = "<leader>bn"; __unkeyed-2 = "<cmd>bnext<cr>"; desc = "Suivant"; }
                { __unkeyed-1 = "<leader>bp"; __unkeyed-2 = "<cmd>bprevious<cr>"; desc = "Précédent"; }
                { __unkeyed-1 = "<leader>bd"; __unkeyed-2 = "<cmd>bdelete<cr>"; desc = "Fermer"; }
              ];
            };

            nvim-autopairs.enable = true;
            comment.enable = true;

            indent-blankline = {
              enable = true;
              settings = {
                indent.char = "│";
                scope.enabled = true;
              };
            };

            colorizer.enable = true;

            lsp = {
              enable = true;
              # Passe les capabilities blink-cmp à tous les serveurs
              capabilities = "require('blink.cmp').get_lsp_capabilities(capabilities)";
              servers = {
                lua_ls = {
                  enable = true;
                  settings.Lua = {
                    diagnostics.globals = [ "vim" ];
                    workspace.checkThirdParty = false;
                  };
                };
                nil_ls.enable = true;
                pyright.enable = true;
                ts_ls.enable = true;
                html.enable = true;
                cssls.enable = true;
                jsonls.enable = true;
                rust_analyzer = {
                  enable = true;
                  installCargo = false;
                  installRustc = false;
                };
                gopls.enable = true;
              };
            };
          };

          diagnostic.settings = {
            virtual_text = true;
            signs = true;
            underline = true;
            update_in_insert = false;
            severity_sort = true;
          };

          keymaps = [
            { key = "<Esc>"; action = "<cmd>nohlsearch<cr>"; mode = [ "n" ]; }
            { key = "K"; action.__raw = "vim.lsp.buf.hover"; mode = [ "n" ]; }
            { key = "[d"; action.__raw = "vim.diagnostic.goto_prev"; mode = [ "n" ]; }
            { key = "]d"; action.__raw = "vim.diagnostic.goto_next"; mode = [ "n" ]; }
            { key = "<C-h>"; action = "<C-w>h"; mode = [ "n" ]; }
            { key = "<C-j>"; action = "<C-w>j"; mode = [ "n" ]; }
            { key = "<C-k>"; action = "<C-w>k"; mode = [ "n" ]; }
            { key = "<C-l>"; action = "<C-w>l"; mode = [ "n" ]; }
          ];

          autoGroups.UserAutocmds.clear = true;
          autoCmd = [
            {
              event = "TextYankPost";
              group = "UserAutocmds";
              desc = "Highlight on yank";
              callback.__raw = ''
                function()
                  vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 150 })
                end
              '';
            }
          ];

          extraConfigLua = ''
            vim.api.nvim_set_hl(0, "YankHighlight", { link = "Visual" })
            vim.opt.shortmess:append("sIcC")
          '';
        };
      }
    );
  };
}
