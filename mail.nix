# Note that the hashedPassword given in the emails should match the same field
# in the users. Maybe down the line define a single list of sets to build
# both from, and not repeat things.

{ config, pkgs, ... }:

let
  release = "nixos-21.05";

in

{
  imports = [
    ( builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      # This hash needs to be updated
      sha256 = "1fwhb7a5v9c98nzhf3dyqf3a5ianqh7k50zizj8v5nmj3blxw4pi";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.leftychan.net";
    domains = [ "leftychan.net" ];
    debug = true;

    # A list of all login accounts. To create the password hashes, use
    # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = {
        "zero@leftychan.net" = {
            hashedPassword = "$6$tpMnAm2wM$jOtRv91BXmdfjcotiIF6F/v931HsuC2qablEY/1GaKeT4EJBKiTKsBKm4FL4KFYVbhvvz5J6FB44Q.BqiQ6iR1";
            aliases = ["0@leftychan.net"];
        };
        "comatoast@leftychan.net" = {
            hashedPassword = "$2y$05$cTk.wYb2GS1zYak2JHzho.hZB8XYYp8trQdwQNFWMC7YEdGRyVsGO";
        };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = 3;
  };


  # Since email user authentication requires a user account on the system, make
  # accounts for everyone for the system to use
  users.extraUsers = {
    comatoast = {
      isSystemUser = true;
      description = "comatoast's account - for email only";
      hashedPassword = "$2y$05$cTk.wYb2GS1zYak2JHzho.hZB8XYYp8trQdwQNFWMC7YEdGRyVsGO";
    };
  };

}
