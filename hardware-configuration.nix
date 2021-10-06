# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.kernelParams = [
    "net.ifnames=0" #Make it use predictable interface names starting with eth0
  ];
  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "pata_atiixp" "floppy" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/951cec3a-0d69-483b-93bb-7dbca0a1379d";
      fsType = "ext4";
    };

  fileSystems."/mnt/hdd" =
    { device = "/dev/sdb";
      fsType = "btrfs";
    };

  fileSystems."/var/lib/matrix-synapse/media" =
    { device = "/mnt/hdd/content/matrix-synapse/media";
      options = [ "bind" ];
    };

  swapDevices = [ ];

}
