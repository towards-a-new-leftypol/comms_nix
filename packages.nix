{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    neovim
    curl
    gitFull
    ripgrep
    xz
    screen
    inetutils
    nmap
    ethtool
    lshw
    python3
    lsof
    btrfs-progs
    synadm
    dig
  ];
}

