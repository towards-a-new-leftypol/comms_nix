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

  users.extraUsers.zero = {
    isNormalUser = true;
    home = "/home/admin";
    description = "zeros account - mainly for email";
    extraGroups = [ "wheel" ];

    hashedPassword = "$6$tpMnAm2wM$jOtRv91BXmdfjcotiIF6F/v931HsuC2qablEY/1GaKeT4EJBKiTKsBKm4FL4KFYVbhvvz5J6FB44Q.BqiQ6iR1";
    openssh.authorizedKeys.keys = [
        # Zer0's key, add your public key here
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCaikScHu09kQvPXu9rJjqPlQZQOeR+xa6v4TUQuXEhQvZDGqb+kbrUzQk17oElr8oZ8sQ6Udb7y7krWWKDKvG3BvUIv/LZLExZ32NHQduA+iAPRVcewXdFy6Xg9F7TPKN3sI8Ply7S2mC0IDAnwBqE3FSVn/rNiDLiKCa2QD+CluVrvnNe/6lWkoM40Q4+7bJhg8s4YlK5K0ozrYtZiLjTD7/MegdudEbUowLP/H2aK+EZOv+xorSHjLR95a7tkf9Ulvm2aO9nUJ+ykWbktATXqaHLssOtJnpNPxdptQH/Y5j7jFF2jQvPxD9sVwsPxsDXP0yU8Cv5tp5ZCjZt1JKH Zer0"
    ];
  };

  users.users.root.hashedPassword = "$6$tpMnAm2wM$jOtRv91BXmdfjcotiIF6F/v931HsuC2qablEY/1GaKeT4EJBKiTKsBKm4FL4KFYVbhvvz5J6FB44Q.BqiQ6iR1";
}
