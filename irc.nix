{ config, pkgs, ... }:

let
  subdomain = "netdata-l.leftychan.net";
  acme_dir = "/var/lib/acme/${subdomain}";
  tls_certificate = "${acme_dir}/fullchain.pem";
  tls_private_key = "${acme_dir}/key.pem";
  irc_admin_passwd = builtins.readFile ./secrets/irc_admin_passwd;

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
}
