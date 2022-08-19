{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    neovim
    curl
    gitAndTools.gitFull
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
  ];
}
