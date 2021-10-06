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
}

