{ config, pkgs, lib, ... }:

{
    services.postgresql = {
        enable = true;
        enableTCPIP = true;
        package = pkgs.postgresql_12;
        # The actual running pg_hba.conf file has stuff after this.
        # Is that why the service won't start? There are duplicated
        # options, at best one of them is ignored.
        authentication = ''
            host    all     all     127.0.0.1/32    password
            host    all     all     localhost       password
        '';
        settings = {
          shared_buffers = "2GB";
          work_mem = "16MB";
        };
    };

    services.postgresqlBackup.enable = true;
    users.extraUsers.postgres = {
      isSystemUser = true;

      openssh.authorizedKeys.keys = [
          # for backups
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBu2RKq+iiu2DoaeMlwhzGGGJww0qP1miyvBJ8OoDc8145XY9kw/LFQ8FbDG8jezszfpe6T6zEbpLFgEoj/ClrA= zer0@localhost"
      ];
    };
}

