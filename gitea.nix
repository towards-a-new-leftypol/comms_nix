{ config, pkgs, ... }:

{
  services.gitea = {
    enable = true;
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
      };
    };
    dump = {
      enable = true;
      backupDir = "/var/backup/gitea";
      type = "tar.gz";
      file = "gitea-dump";
    };
  };

  users.extraUsers.gitea = {
    isSystemUser = true;

    openssh.authorizedKeys.keys = [
        # for backups
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBu2RKq+iiu2DoaeMlwhzGGGJww0qP1miyvBJ8OoDc8145XY9kw/LFQ8FbDG8jezszfpe6T6zEbpLFgEoj/ClrA= zer0@localhost"
    ];
  };
}
