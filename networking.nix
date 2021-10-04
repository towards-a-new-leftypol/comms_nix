{ config, pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80
    443
  ];
}
