{ config, pkgs, lib, ... }:

let
  subdomain = "netdata-l2.leftychan.net";

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

  # Since we are proxied by cloudflare, read the real ip from the header
  cloudflareExtraConfig = ''
    # Cloudflare IPv4 addresses
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;


    # Cloudflare IPv6 addresses
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2a06:98c0::/29;
    set_real_ip_from 2c0f:f248::/32;

    real_ip_header CF-Connecting-IP;
  '';
in

{
  environment.systemPackages = with pkgs; [
    element-web
  ];

  security.acme = {
    defaults = {
        email = "paul_cockshott@protonmail.com";
        # use staging server to debug
        #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
    acceptTerms = true;
    certs."${subdomain}" = {
      group = "nginx";

      extraDomainNames = [
        "talk.leftychan.net"
        "matrix.leftychan.net"
        "git.leftychan.net"
        "irc.leftychan.net"
        "appservice-irc.leftychan.net"
      ];

      postRun = "systemctl reload nginx"
        + lib.optionalString config.services.matrix-synapse.enable " matrix-synapse; "
        + lib.optionalString config.services.coturn.enable " systemctl restart coturn;"
        + lib.optionalString config.services.ngircd.enable " systemctl restart ngircd";
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "1024m";

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
      useACMEHost = subdomain;
      forceSSL = true;

      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;

      locations."/".extraConfig = '' 


        return 404;
      '';

      locations."/_matrix".proxyPass = "http://[::1]:8030";
      locations."/_synapse/client".proxyPass = "http://[::1]:8030";

      extraConfig = cloudflareExtraConfig;

      listen = [
        { addr = "0.0.0.0"; port = 8448; ssl = true; }
        { addr = "0.0.0.0"; port = 443; ssl = true; }
      ];
    };

    virtualHosts."talk.leftychan.net" = {
      useACMEHost = subdomain;
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

      extraConfig = cloudflareExtraConfig + ''
          client_max_body_size 10000M; 
      '';

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

    virtualHosts."git.leftychan.net" = {
      useACMEHost = subdomain;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:3000";
        };
      };

      extraConfig = cloudflareExtraConfig + ''
        add_header Onion-Location http://git.${onion}$request_uri;
      '';

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

    virtualHosts."appservice-irc.leftychan.net" = {
      useACMEHost = subdomain;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8009";
        };
      };

      extraConfig = cloudflareExtraConfig;

      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
      ];
    };

  };
}
