{ lib, ... }:
{
  imports = [ ./impermanence.nix ];

  # Safe on NixOS (known bugs on macOS only)
  nix.settings.auto-optimise-store = true;

  # GC uses systemd on NixOS
  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    options = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot = {
    enable = lib.mkDefault true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  networking.networkmanager.enable = lib.mkDefault true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  system.stateVersion = lib.mkDefault "24.11";
}
