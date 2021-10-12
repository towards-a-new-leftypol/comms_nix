{ config, pkgs, ... }:

let

  turn_shared_secret = "gq0asuRE02/llax0MlDXzXyOm3j1Xfn8Db6jfTWf";

  #These are defined in http.nix
  #may need to chmod as a hack for matrix-synapse
  acme_dir = "/var/lib/acme";
  tls_certificate = "${acme_dir}/netdata-l.leftychan.net/fullchain.pem";
  tls_private_key = "${acme_dir}/netdata-l.leftychan.net/key.pem";

  external_ip = "198.204.240.194";

  recaptcha_pk = builtins.readFile ./secrets/recaptcha_private_key;
  db_password = builtins.readFile ./secrets/database-password;
in

{

  nixpkgs.config.packageOverrides = pkgs: {
    coturn = pkgs.coturn.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.postgresql_12 ];
    });
  };

  # see users.nix for extra groups these server users are in
  # extra users are needed to read keys from the acme directory

  services.coturn = {
    enable = true;
    lt-cred-mech = true;
    use-auth-secret = true;
    static-auth-secret = turn_shared_secret;
    realm = "matrix.leftychan.net";
    cert = tls_certificate;
    pkey = tls_private_key;
    extraConfig = ''
      psql-userdb="host=localhost dbname=turn user=turn_user password=${db_password} connect_timeout=30"
      server-name=matrix.leftychan.net
      verbose
      mobility
      no-tlsv1
      no-tlsv1_1
      external-ip=${external_ip}
    '';
    min-port = 49152;
    max-port = 49999;
  };

  services.matrix-synapse = {
    enable = true;
    #no_tls = true;

    #listeners = [{
    #  port = 8030;
    #  bind_address = "";
    #  type = "http";
    #  tls = false;
    #  x_forwarded = false;
    #  resources = [
    #    { names = ["client" "webclient"]; compress = true; }
    #    { names = ["federation"]; compress = false; }
    #  ];
    #}];


    listeners = [
      {
        port = 8030;
        tls = false;
        x_forwarded = true;
        resources = [
          { names = ["client"]; compress = true; }
        ];
      }

      {
        port = 8448;
        tls = true;
        resources = [
          { names = ["federation"]; compress = false; }
        ];
      }
    ];

    server_name = "matrix.leftychan.net";
    tls_certificate_path = tls_certificate;
    tls_private_key_path = tls_private_key;
    enable_registration = true;
    enable_registration_captcha = true;
    recaptcha_private_key = recaptcha_pk;
    recaptcha_public_key = "6Ldqya8cAAAAAGO8-WREEtz8FWmO-xNQp3H91X4R";
    #registration_shared_secret  = "applepiejumboshrimp";

    public_baseurl = "https://matrix.leftychan.net:443/";
    database_type = "psycopg2";
    database_args = {
      password = db_password;
    };
    turn_uris = [
      "turn:matrix.leftychan.net:5349?transport=udp"
      "turn:matrix.leftychan.net:5350?transport=udp"
      "turn:matrix.leftychan.net:5349?transport=tcp"
      "turn:matrix.leftychan.net:5350?transport=tcp"
    ];
    turn_shared_secret = turn_shared_secret;
    turn_user_lifetime = "7200000";
    max_upload_size = "1000M";
    max_image_pixels = "64M";
    dynamic_thumbnails = true;
    allow_guest_access = true;
    logConfig = ''
      version: 1

      # In systemd's journal, loglevel is implicitly stored, so let's omit it
      # from the message text.
      formatters:
          journal_fmt:
              format: '%(name)s: [%(request)s] %(message)s'

      filters:
          context:
              (): synapse.util.logcontext.LoggingContextFilter
              request: ""

      handlers:
          journal:
              class: systemd.journal.JournalHandler
              formatter: journal_fmt
              filters: [context]
              SYSLOG_IDENTIFIER: synapse

      root:
          level: WARNING
          handlers: [journal]

      disable_existing_loggers: False
    '';
  };

  users.extraUsers.matrix-synapse.extraGroups = [ "nginx" ];
  users.extraUsers.matrix-synapse.isSystemUser = true;
  users.extraUsers.turnserver.extraGroups = [ "nginx" ];
  users.extraUsers.turnserver.isSystemUser = true;
}

