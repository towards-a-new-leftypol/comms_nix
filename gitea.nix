{ config, pkgs, lib, ... }:

{
  services.gitea = {
    enable = false;
    settings = {
      mailer = {
        ENABLED = true;
        FROM = "git@leftychan.net";
        MAILER_TYPE = "smtps";
        HOST = "mail.leftychan.net:465";
        IS_TLS_ENABLED = true;
        USER = "git@leftychan.net";
        PASSWD = builtins.readFile ./secrets/git_mail_password;
      };
      server = {
        DOMAIN = "git.leftychan.net";
        ROOT_URL = "https://git.leftychan.net/";
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
    };
    dump = {
      enable = false;
      backupDir = "/var/backup/gitea";
      type = "tar.gz";
      file = "gitea-dump";
    };
  };

  users.groups.gitea = {};

  users.users.gitea-backup = lib.mkIf config.services.gitea.dump.enable {
    isNormalUser = true;
    group = "gitea";
    createHome = false;
    home = config.services.gitea.dump.backupDir;

    openssh.authorizedKeys.keys = [
        # for backups
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBu2RKq+iiu2DoaeMlwhzGGGJww0qP1miyvBJ8OoDc8145XY9kw/LFQ8FbDG8jezszfpe6T6zEbpLFgEoj/ClrA= zer0@localhost"
    ];
  };

  systemd.services.gitea-dump-perms-fix = let
    gitea_config = config.services.gitea;
  in

  lib.mkIf gitea_config.dump.enable {
    description = "gitea dump file permissions fix";

    after = [ "gitea-dump.service" ];
    requires = [ "gitea-dump.service" ];
    partOf = [ "gitea-dump.service" ];
    wantedBy = [ "gitea-dump.service" ];

    environment = {
      USER = "gitea";
      HOME = "/var/backup/gitea";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "gitea";
      ExecStart = "${pkgs.coreutils}/bin/chmod 660 ${gitea_config.dump.backupDir}/${gitea_config.dump.file}.${gitea_config.dump.type}";
      WorkingDirectory = gitea_config.dump.backupDir;
    };
  };
}
