{ config, pkgs, lib, ... }:

let
  subdomain = "netdata-l.leftychan.net";
  acme_dir = "/var/lib/acme/${subdomain}";
  tls_certificate = "${acme_dir}/fullchain.pem";
  tls_private_key = "${acme_dir}/key.pem";
  irc_admin_passwd = lib.fileContents ./secrets/irc_admin_passwd;
  db_passwd = lib.fileContents ./secrets/matrix-appservice-irc-database-password;

  motd_literal = ''
 ___           ___ __              __                               __   
|   |  .-----.'  _|  |_.--.--.----|  |--.---.-.-----.  .-----.-----|  |_ 
|.  |  |  -__|   _|   _|  |  |  __|     |  _  |     |__|     |  -__|   _|
|.  |__|_____|__| |____|___  |____|__|__|___._|__|__|__|__|__|_____|____|
|:  1   |              |_____|                                           
|::.. . |                                                                
`-------'                                                                
                                                                         
  '';

  motd = pkgs.writeText "irc_motd" motd_literal;

in

{
  imports = [ ./appservice-irc.nix ];

  services.ngircd.enable = true;
  services.ngircd.config = ''
    [Global]
	Name = irc.leftychan.net

	AdminInfo1 = Leftychan irc server
	AdminInfo2 = leftychan.net
	AdminEMail = zero@leftychan.net

	MotdFile = ${motd}

    Ports = 6667

    [SSL]
	CertFile = ${tls_certificate}
	KeyFile = ${tls_private_key}
	Ports = 6697, 9999

    [Operator]
    Name = admin
	Password = ${irc_admin_passwd}

    [Options]
    PAM = no
    '';

  users.extraUsers.ngircd.extraGroups = [ "nginx" ];
  users.extraUsers.ngircd.isSystemUser = true;

  services.my-matrix-appservice-irc = {
    enable = true;
    port = 8009;
    registrationUrl = "http://matrix.leftychan.net:8009";
    settings = {
      database = {
        connectionString = "postgresql://ircbridge:${db_passwd}@localhost:5432/ircbridge";
        engine = "postgres";
      };
      homeserver = {
        domain = "matrix.leftychan.net";
        url = config.services.matrix-synapse.settings.public_baseurl;
      };
      ircService = {
        servers = {
          "irc.leftychan.net" = {
            name = "Leftychan";
            port = 6697;
            ssl = true;
            sasl = false;
            membershipLists = {
              enabled = true;
              global = {
                ircToMatrix = {
                  initial = true;
                  incremental = true;
                };
                matrixToIrc = {
                  initial = true;
                  incremental = true;
                };
              };
              ignoreIdleUsersOnStartup = {
                enabled = true;
                idleForHours = 720;
              };
            };
            mappings = {
              "#leftychan" = {
                roomIds = [ "!pzUwATCHBFSmplsmxu:matrix.org" ];
              };
            };
            ircClients = {
              allowNickChanges = true;
              maxClients = 300;
            };
          };
        };
      };
    };
  };

  users.groups.matrix-appservice-irc = {};
  users.users.matrix-appservice-irc.group = "matrix-appservice-irc";
  users.users.matrix-appservice-irc.extraGroups = [ "matrix-synapse" ];
  users.users.matrix-appservice-irc.isSystemUser = true;
}
