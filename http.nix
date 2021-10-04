{ config, pkgs, lib, ... }:

let
  subdomain = "netdata-l.leftychan.net";

in

{
  security.acme = {
    email = "paul_cockshott@protonmail.com";
    acceptTerms = true;
    certs."${subdomain}" = {
      group = "nginx";
      # extraDomainNames = [
      #   "matrix.leftychan.net"
      #   "talk.leftychan.net"
      # ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;

    virtualHosts."${subdomain}" = {
      enableACME = true;
      addSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8020";
        };
      };

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };
  };
}
