{ config, pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # ssh

    # HTTP
    80
    443

    #matrix-synapse
    8448 #tls port for federation

    #murmur (mumble server)
    64738

    #turn server (needed for synapse)
    3478 # tcp port
    3479 # alt tcp port
    5349 # tls tcp port
    5350 # alt tls tcp port
  ];

  networking.firewall.allowedUDPPorts = [
    #murmur (mumble server)
    64738
  ];

  networking.firewall.allowedUDPPortRanges = [
    { from = 41952; to = 49999; }
    { from = 51416; to = 51500; }
  ];

}
