{ config, pkgs, ... }:

{
  services.murmur = {
    enable = true;
    hostName = "mumble.leftychan.net";
    welcometext = ''
       ___           ___ __              __                               __   
      |   |  .-----.'  _|  |_.--.--.----|  |--.---.-.-----.  .-----.-----|  |_ 
      |.  |  |  -__|   _|   _|  |  |  __|     |  _  |     |__|     |  -__|   _|
      |.  |__|_____|__| |____|___  |____|__|__|___._|__|__|__|__|__|_____|____|
      |:  1   |              |_____|                                           
      |::.. . |                                                                
      `-------'                                                                

      -- welcome --
                                                                         
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
  };

  users.groups.nginx.members = [ "murmur" ];
}
