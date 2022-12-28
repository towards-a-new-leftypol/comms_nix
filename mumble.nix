{ config, pkgs, ... }:

{
  services.murmur = {
    enable = true;
    hostName = "mumble.leftychan.net";
    welcometext = ''
      L E F T Y C H A N . N E T -- welcome --
                                                                         
    '';

    users = 500;
    textMsgLength = 100000;
    registerName = "Leftychan public server";
    registerUrl = "https://leftychan.net";
    registerHostname = "mumble.leftychan.net";
    clientCertRequired = true;
    sslCert = "/var/lib/acme/mumble.leftychan.net/fullchain.pem";
    sslKey = "/var/lib/acme/mumble.leftychan.net/key.pem";
  };

  security.acme.certs."mumble.leftychan.net" = {
    group = "nginx";
    postRun = "systemctl reload murmur.service";
  };

  users.groups.nginx.members = [ "murmur" ];
}
