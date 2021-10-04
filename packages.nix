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
    telnet
    ncat
    ethtool
    lshw
    python3
  ];
}
