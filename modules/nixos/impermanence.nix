{ lib, config, ... }:
let
  cfg = config.impermanence;
in
{
  options.impermanence = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tmpfs root with selective persistence.";
    };

    persistDir = lib.mkOption {
      type = lib.types.str;
      default = "/nix/persist";
      description = "Path for persisting data across reboots.";
    };

    tmpfsSize = lib.mkOption {
      type = lib.types.str;
      default = "2G";
      description = "Size of the tmpfs root filesystem.";
    };

    dirList = lib.mkOption {
      type = lib.types.listOf (lib.types.coercedTo lib.types.str (d: { directory = d; }) lib.types.attrs);
      default = [ ];
      description = "Directories to persist.";
    };

    fileList = lib.mkOption {
      type = lib.types.listOf (lib.types.coercedTo lib.types.str (f: { file = f; }) lib.types.attrs);
      default = [ ];
      description = "Files to persist.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo.extraConfig = "Defaults lecture=never";

    environment.persistence.${cfg.persistDir} = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/systemd"
      ]
      ++ cfg.dirList;
      files = [
        "/etc/machine-id"
      ]
      ++ cfg.fileList;
    };

    fileSystems = {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=${cfg.tmpfsSize}"
          "mode=755"
        ];
      };
      "/nix" = {
        device = "/dev/disk/by-partlabel/nix-persist";
        fsType = "ext4";
        neededForBoot = true;
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/nix-boot";
        fsType = "vfat";
      };
    };
  };
}
