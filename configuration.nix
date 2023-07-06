# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
      ./networking.nix
      ./packages.nix
      #./netdata.nix
      #./http.nix
      #./postgresql.nix
      #./matrix.nix
      #./mail.nix
      #./mumble.nix
      #./gitea.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 10;

  networking.hostName = "PUSHKA"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "UTC";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;

  networking = {
    defaultGateway = {
      address = "198.204.240.193";
      interface = "eth1";
    };
    # Use google's public DNS server
    nameservers = [ "8.8.8.8" ];
    interfaces.eth0.useDHCP = false;
    interfaces.eth1 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "198.204.240.194";
          prefixLength = 29;
        }
      ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

