{
  den.aspects.zsh = {
    nixos = { ... }: {
      programs.zsh.enable = true;
    };

    homeManager = { ... }: {
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
          aws.symbol = " ";
          buf.symbol = " ";
          bun.symbol = " ";
          c.symbol = " ";
          cpp.symbol = " ";
          cmake.symbol = " ";
          conda.symbol = " ";
          crystal.symbol = " ";
          dart.symbol = " ";
          deno.symbol = " ";
          directory.read_only = " 󰌾";
          docker_context.symbol = " ";
          elixir.symbol = " ";
          elm.symbol = " ";
          fennel.symbol = " ";
          fortran.symbol = " ";
          fossil_branch.symbol = " ";
          gcloud.symbol = " ";
          git_commit.tag_symbol = "  ";
          git_commit.disabled = true;
          git_branch.disabled = true;
          git_state.disabled = true;
          git_status.disabled = true;
          git_metrics.disabled = true;
          golang.symbol = " ";
          gradle.symbol = " ";
          guix_shell.symbol = " ";
          haskell.symbol = " ";
          haxe.symbol = " ";
          hg_branch.symbol = " ";
          hostname.ssh_symbol = " ";
          java.symbol = " ";
          julia.symbol = " ";
          kotlin.symbol = " ";
          lua.symbol = " ";
          memory_usage.symbol = "󰍛 ";
          meson.symbol = "󰔷 ";
          nim.symbol = "󰆥 ";
          nix_shell.symbol = " ";
          nodejs.symbol = " ";
          ocaml.symbol = " ";
          package.symbol = "󰏗 ";
          perl.symbol = " ";
          php.symbol = " ";
          pijul_channel.symbol = " ";
          pixi.symbol = "󰏗 ";
          python.symbol = " ";
          rlang.symbol = "󰟔 ";
          ruby.symbol = " ";
          rust.symbol = "󱘗 ";
          scala.symbol = " ";
          status.symbol = " ";
          swift.symbol = " ";
          xmake.symbol = " ";
          zig.symbol = " ";
          custom = {
            jj = {
              description = "The current jj status";
              when = "jj --ignore-working-copy root";
              symbol = "🥋 ";
              command = "jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template ' separate(\" \", change_id.shortest(4), bookmarks, \"|\", concat( if(conflict, \"💥\"), if(divergent, \"🚧\"), if(hidden, \"👻\"), if(immutable, \"🔒\"), ), raw_escape_sequence(\"\\x1b[1;32m\") ++ if(empty, \"(empty)\"), raw_escape_sequence(\"\\x1b[1;32m\") ++ coalesce( truncate_end(29, description.first_line(), \"…\"), \"(no description set)\", ) ++ raw_escape_sequence(\"\\x1b[0m\"), ) '";
              shell = [ "sh" "--norc" "--noprofile" ];
            };
            git_status = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_status";
              style = "";
              description = "Only show git_status if we're not in a jj repo";
              shell = [ "sh" "--norc" "--noprofile" ];
            };
            git_commit = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_commit";
              style = "";
              description = "Only show git_commit if we're not in a jj repo";
              shell = [ "sh" "--norc" "--noprofile" ];
            };
            git_metrics = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_metrics";
              style = "";
              description = "Only show git_metrics if we're not in a jj repo";
              shell = [ "sh" "--norc" "--noprofile" ];
            };
            git_branch = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_branch";
              style = "";
              description = "Only show git_branch if we're not in a jj repo";
              shell = [ "sh" "--norc" "--noprofile" ];
            };
          };
        };
      };
    };
  };
}
