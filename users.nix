{ config, ... }:

{
  users.mutableUsers = false;
  users.motd = ''
   _______ ___ ___ _______ ___ ___ ___ ___  _______ 
  |   _   |   Y   |   _   |   Y   |   Y   )|   _   |
  |.  1   |.  |   |   1___|.  1   |.  1  / |.  1   |
  |.  ____|.  |   |____   |.  _   |.  _  \ |.  _   |
  |:  |   |:  1   |:  1   |:  |   |:  |   \|:  |   |
  |::.|   |::.. . |::.. . |::.|:. |::.| .  |::.|:. |
  `---'   `-------`-------`--- ---`--- ---'`--- ---'

          (Production system, NixOS 21.05)
  '';

  users.extraUsers.admin = {
    isNormalUser = true;
    home = "/home/admin";
    description = "Sysadmin account. SSH into this.";
    extraGroups = [ "wheel" ];

    # the password is password
    hashedPassword = "$6$mV1wguq77UrIH$i/gftmJYcg.OP6d3PgTTOmE/cQqGNqpspPYdwOc04otsdqkpLj1YKoa1QWp7Z.MApwofxawlQzfSGfO4AiUN2.";
    openssh.authorizedKeys.keys = [
        # Zer0's key, add your public key here
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBu2RKq+iiu2DoaeMlwhzGGGJww0qP1miyvBJ8OoDc8145XY9kw/LFQ8FbDG8jezszfpe6T6zEbpLFgEoj/ClrA= zer0@localhos"
    ];
  };

  users.users.root.hashedPassword = "$6$tpMnAm2wM$jOtRv91BXmdfjcotiIF6F/v931HsuC2qablEY/1GaKeT4EJBKiTKsBKm4FL4KFYVbhvvz5J6FB44Q.BqiQ6iR1";
}
