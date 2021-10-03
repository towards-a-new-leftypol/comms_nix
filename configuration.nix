# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 10;

  networking.hostName = "PUSHKA"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "UTC";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  networking = {
    defaultGateway = "198.204.240.193";
    # Use google's public DNS server for now
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    neovim
    curl
    gitAndTools.gitFull
    ripgrep
    xz
    screen
    telnet
    ncat
    ethtool
    lshw
    python3
  ];

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

  users.users.root.hashedPassword = "$6$tpMnAm2wM$jOtRv91BXmdfjcotiIF6F/v931HsuC2qablEY/1GaKeT4EJBKiTKsBKm4FL4KFYVbhvvz5J6FB44Q.BqiQ6iR1";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCaikScHu09kQvPXu9rJjqPlQZQOeR+xa6v4TUQuXEhQvZDGqb+kbrUzQk17oElr8oZ8sQ6Udb7y7krWWKDKvG3BvUIv/LZLExZ32NHQduA+iAPRVcewXdFy6Xg9F7TPKN3sI8Ply7S2mC0IDAnwBqE3FSVn/rNiDLiKCa2QD+CluVrvnNe/6lWkoM40Q4+7bJhg8s4YlK5K0ozrYtZiLjTD7/MegdudEbUowLP/H2aK+EZOv+xorSHjLR95a7tkf9Ulvm2aO9nUJ+ykWbktATXqaHLssOtJnpNPxdptQH/Y5j7jFF2jQvPxD9sVwsPxsDXP0yU8Cv5tp5ZCjZt1JKH Zer0@leftchan"
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

