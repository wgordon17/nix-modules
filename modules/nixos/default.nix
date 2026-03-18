{ config, lib, ... }:
{
  # Guard nix.* for consistency (NixOS defaults nix.enable = true,
  # but Determinate Nix on NixOS would set it false)
  nix.settings.auto-optimise-store = lib.mkIf config.nix.enable true;

  nix.gc = lib.mkIf config.nix.enable {
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
