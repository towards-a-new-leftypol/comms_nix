# TODO: Note that the hashedPassword given in the emails should match the same field
# in the users. Maybe down the line define a single list of sets to build
# both from, and not repeat things.

{ config, pkgs, ... }:

let
  release = "nixos-21.11";

in

{
  imports = [
    ( builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      # This hash needs to be updated
      sha256 = "1i56llz037x416bw698v8j6arvv622qc0vsycd20lx3yx8n77n44";
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
            hashedPassword = "$2y$05$Hfa0MTgivLek/iEWaUlReunpkY3g6As87Oqo516aJZuUCGzbAnZty";
        };
        #pine
        "rockstar@leftychan.net" = {
            hashedPassword = "$2y$05$UpONRXLVqXdgT47HeUcaaee1fyNd/4Zo/ogezmhNLVudgqkMGbd3.";
        };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = 3;
  };


  users.groups = {
    email_only = {};
  };

  # Since email user authentication requires a user account on the system, make
  # accounts for everyone for the system to use
  users.extraUsers = {
    comatoast = {
      isSystemUser = true;
      description = "comatoast's account - for email only";
      hashedPassword = "$2y$05$Hfa0MTgivLek/iEWaUlReunpkY3g6As87Oqo516aJZuUCGzbAnZty";
      group = "email_only";
    };

    zero = {
      isSystemUser = true;
      description = "zeros account - mainly for email";
      hashedPassword = "$6$tpMnAm2wM$jOtRv91BXmdfjcotiIF6F/v931HsuC2qablEY/1GaKeT4EJBKiTKsBKm4FL4KFYVbhvvz5J6FB44Q.BqiQ6iR1";
      group = "email_only";
    };

    rockstar = {
      isSystemUser = true;
      description = "pine's account - for email only";
      hashedPassword = "$2y$05$UpONRXLVqXdgT47HeUcaaee1fyNd/4Zo/ogezmhNLVudgqkMGbd3.";
      group = "email_only";
    };
  };

}
