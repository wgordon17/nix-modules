{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
{
  # On darwin with Determinate Nix, nix.enable = false. Guard all nix.* options.
  nix = lib.mkIf config.nix.enable {
    settings = {
      trusted-users = [ "@wheel" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Note: auto-optimise-store has known bugs on macOS (can cause build failures).
      # Defaulting to false here; NixOS module enables it explicitly.
      auto-optimise-store = lib.mkDefault false;
    };

    # Pin nix registry so `nix shell nixpkgs#foo` uses the same nixpkgs as the system
    registry.nixpkgs.to = {
      type = "path";
      path = inputs.nixpkgs.outPath;
    };
  };

  # Track which git revision built this system (shows in `nixos-version` / `darwin-rebuild --list-generations`)
  system.configurationRevision = self.rev or self.dirtyRev or null;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  # Guard: block password/hashedPassword options that leak to the Nix store
  assertions = [
    {
      assertion =
        !(builtins.any (u: u.password or null != null) (builtins.attrValues config.users.users));
      message = ''
        users.users.*.password stores plaintext in /nix/store (world-readable).
        Use hashedPasswordFile with sops-nix instead, or initialHashedPassword
        with users.mutableUsers = false for bootstrapping.
      '';
    }
    {
      assertion =
        !(builtins.any (u: u.hashedPassword or null != null) (builtins.attrValues config.users.users));
      message = ''
        users.users.*.hashedPassword stores the hash in /nix/store (world-readable,
        brute-forceable). Use hashedPasswordFile with sops-nix instead.
      '';
    }
  ];
}
