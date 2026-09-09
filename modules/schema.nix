{ lib, den, ... }:
{
  # Types the freeform per-entity data consumed via `{ user, host, ... }:`
  # (see hosts.nix, hyprland.nix, git.nix, jujutsu.nix, protonpass.nix,
  # razer.nix). Without this, a typo like `monitorss` silently evaluates
  # to an empty attrset and the `or [ ]` fallback in hyprland.nix hides it
  # completely — Hyprland just falls back to auto-detected monitors with
  # no error anywhere. Deliberately shallow: outer keys are typed (catches
  # the typo), inner shapes stay loose (`attrsOf anything`) rather than
  # fully-specified submodules — see CLAUDE.md's guidance against
  # typing everything.
  den.schema.user.imports = [
    {
      options = {
        fullName = lib.mkOption {
          type = lib.types.str;
          description = "Full name, used for Git/Jujutsu commit authorship.";
        };
        email = lib.mkOption {
          type = lib.types.str;
          description = "Email, used for Git/Jujutsu commit authorship and SSH signature verification.";
        };
        signingKey = lib.mkOption {
          type = lib.types.str;
          description = "SSH public key used to sign Git/Jujutsu commits.";
        };
        protonPassIdentity = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Proton Pass's own identity/vault label for `pass-cli ssh-agent --create-new-identities` — not assumed to match fullName or the Unix username.";
        };
      };
    }
  ];

  den.schema.host.imports = [
    {
      options.hyprland = lib.mkOption {
        default = { };
        description = "Host-specific Hyprland wiring consumed by den.aspects.hyprland.";
        type = lib.types.submodule {
          options = {
            monitors = lib.mkOption {
              type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
              default = [ ];
              description = "wayland.windowManager.hyprland.settings.monitor entries.";
            };
            workspaceRules = lib.mkOption {
              type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
              default = [ ];
              description = "wayland.windowManager.hyprland.settings.workspace_rule entries.";
            };
            nvidia = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to apply NVIDIA-specific env vars/cursor/render tuning.";
            };
            defaultMonitor = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Hyprland cursor.default_monitor.";
            };
            logindOverrides = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = "services.logind.settings.Login overrides (e.g. HandleLidSwitch).";
            };
          };
        };
      };
    }
  ];
}
