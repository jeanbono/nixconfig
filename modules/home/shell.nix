{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.shell;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  options.modules.home.shell.enable = lib.mkEnableOption "Zsh + Alacritty (shell complet)";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        aws = {
          symbol = " ";
        };
        buf = {
          symbol = " ";
        };
        bun = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        cpp = {
          symbol = " ";
        };
        cmake = {
          symbol = " ";
        };
        conda = {
          symbol = " ";
        };
        crystal = {
          symbol = " ";
        };
        dart = {
          symbol = " ";
        };
        deno = {
          symbol = " ";
        };
        directory = {
          read_only = " 󰌾";
        };
        docker_context = {
          symbol = " ";
        };
        elixir = {
          symbol = " ";
        };
        elm = {
          symbol = " ";
        };
        fennel = {
          symbol = " ";
        };
        fortran = {
          symbol = " ";
        };
        fossil_branch = {
          symbol = " ";
        };
        gcloud = {
          symbol = " ";
        };
        git_commit = {
          tag_symbol = "  ";
        };
        golang = {
          symbol = " ";
        };
        gradle = {
          symbol = " ";
        };
        guix_shell = {
          symbol = " ";
        };
        haskell = {
          symbol = " ";
        };
        haxe = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        hostname = {
          ssh_symbol = " ";
        };
        java = {
          symbol = " ";
        };
        julia = {
          symbol = " ";
        };
        kotlin = {
          symbol = " ";
        };
        lua = {
          symbol = " ";
        };
        memory_usage = {
          symbol = "󰍛 ";
        };
        meson = {
          symbol = "󰔷 ";
        };
        nim = {
          symbol = "󰆥 ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        ocaml = {
          symbol = " ";
        };
        package = {
          symbol = "󰏗 ";
        };
        perl = {
          symbol = " ";
        };
        php = {
          symbol = " ";
        };
        pijul_channel = {
          symbol = " ";
        };
        pixi = {
          symbol = "󰏗 ";
        };
        python = {
          symbol = " ";
        };
        rlang = {
          symbol = "󰟔 ";
        };
        ruby = {
          symbol = " ";
        };
        rust = {
          symbol = "󱘗 ";
        };
        scala = {
          symbol = " ";
        };
        status = {
          symbol = " ";
        };
        swift = {
          symbol = " ";
        };
        xmake = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        general = {
          import = [ themeCfg.alacrittyThemeFile ];
        };
        window = {
          opacity = 0.4;
          padding = {
            x = 10;
            y = 10;
          };
        };
        font = {
          normal = {
            family = "MonaspiceNe Nerd Font";
          };
        };
        cursor = {
          style = "Block";
          blink_interval = 0;
        };
      };
    };
  };
}
