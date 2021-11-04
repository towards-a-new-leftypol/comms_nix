{ config, pkgs, lib, ... }:

let
  subdomain = "netdata-l.leftychan.net";

  riot_config = {
    default_hs_url = "https://matrix.leftychan.net";
    default_is_url = "https://matrix.org";
    showLabsSettings = true;
  };

  riot_config_file = pkgs.writeText "config.json" (builtins.toJSON riot_config);
in

{
  environment.systemPackages = with pkgs; [
    element-web
  ];

  security.acme = {
    email = "paul_cockshott@protonmail.com";
    acceptTerms = true;
    certs."${subdomain}" = {
      group = "nginx";

      extraDomainNames = [
        "talk.leftychan.net"
        "matrix.leftychan.net"
      ];

      postRun = "systemctl reload nginx"
        + lib.optionalString config.services.matrix-synapse.enable " matrix-synapse; "
        + lib.optionalString config.services.coturn.enable " systemctl restart coturn";

    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

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

    virtualHosts."matrix.leftychan.net" = {
      enableACME = true;
      addSSL = true;

      locations = {
        "= /" = {
          return = "$scheme://talk.leftychan.net$request_uri";
        };

        "/" = {
          proxyPass = "http://127.0.0.1:8030";
        };
      };

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

    virtualHosts."talk.leftychan.net" = {
      enableACME = true;
      forceSSL = true;

      root = "${pkgs.element-web}";

      locations = {
        "=/config.json" = {
          alias = "${riot_config_file}";
        };
        "=/config.talk.leftychan.net.json" = {
          alias = "${riot_config_file}";
        };
      };

      extraConfig = ''
          client_max_body_size 10000M; 
      '';

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

  };
}
