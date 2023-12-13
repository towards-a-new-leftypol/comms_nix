{ config, pkgs, lib, ... }:

let
  subdomain = "netdata-l.leftychan.net";

  onion = "leftychans5gstl4zee2ecopkv6qvzsrbikwxnejpylwcho2yvh4owad.onion";

  riot_config = {
    default_hs_url = "https://matrix.leftychan.net";
    default_is_url = "https://matrix.org";
    showLabsSettings = true;
  };

  riot_config_file = pkgs.writeText "config.json" (builtins.toJSON riot_config);

  clientConfig = {
    "m.homeserver".base_url = "https://matrix.leftychan.net";
    "m.identity_server" = {};
  };
  serverConfig."m.server" = "matrix.leftychan.net";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in

{
  environment.systemPackages = with pkgs; [
    element-web
  ];

  security.acme = {
    defaults.email = "paul_cockshott@protonmail.com";
    acceptTerms = true;
    certs."${subdomain}" = {
      group = "nginx";

      extraDomainNames = [
        "talk.leftychan.net"
        "matrix.leftychan.net"
        "git.leftychan.net"
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
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

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

    virtualHosts."mumble.leftychan.net" = {
      enableACME = true;
      addSSL = true;

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

    virtualHosts."matrix.leftychan.net" = {
      enableACME = true;
      forceSSL = true;

      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;

      locations."/".extraConfig = '' 


        return 404;
      '';

      locations."/_matrix".proxyPass = "http://[::1]:8030"; 
      locations."/_synapse/client".proxyPass = "http://[::1]:8030"; 

      listen = [
        { addr = "0.0.0.0"; port = 8448; ssl = true; }
        { addr = "0.0.0.0"; port = 443; ssl = true; }
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

    virtualHosts."git.leftychan.net" = {
      enableACME = true;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:3000";
        };
      };

      extraConfig = ''
        add_header Onion-Location http://git.${onion}$request_uri;
      '';

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

  };
}
