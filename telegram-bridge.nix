{ config, pkgs, lib, ... }:

let
  db_passwd = lib.fileContents ./secrets/mautrix-telegram-database-password;

in

{
  services.mautrix-telegram = {
    enable = true;
    settings = {
      homeserver = {
        address = "https://matrix.leftychan.net";
        domain = "matrix.leftychan.net";
        verify_ssl = true;
        software = "standard";
        http_retry_count = 4;
      };
      appservice = {
        address = "http://localhost:29317";
        tls_cert = false;
        tls_key = false;
        hostname = "0.0.0.0";
        port = 29317;
        database = "postgres://telegram_bridge:${db_passwd}@localhost/telegram_bridge";
        database_opts = {};
      };
      bridge = {
        username_template = "T-{userid}";
        alias_template = "T-{groupname}";
        displayname_template = "{displayname} (Telegram)";
        max_initial_member_sync = 200;
        sync_channel_members = true;
        startup_sync = true;
        sync_matrix_state = true;
        allow_matrix_login = true;
        sync_with_custom_puppets = true;
        sync_direct_chat_list = true;
        double_puppet_server_map = {
        };
      };
    };
  };
}
