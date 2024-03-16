{ config, ... }:

let
  keyname = "leftypolmatpqjy3d653eqncfblx6iaze6dlxcax6r6asbito2tq.dat";

in

{
  ## I2P Eepsite
  services.i2pd = {
    enable     = true;
    enableIPv4 = true;
    enableIPv6 = true;

    port       = 4400;
    ntcp2.port = 4401;
    ntcp2.published = true;

    inTunnels = {
      leftychan_irc_ssl = {
        enable = true;
        keys = keyname;
        inPort = 6697;
        address = "127.0.0.1";
        destination = "127.0.0.1";
        port = 9999;
        inbound.length = 1;
        outbound.length = 1;
      };
    };

    inTunnels = {
      leftychan_irc = {
        enable = true;
        keys = keyname;
        inPort = 6667;
        address = "127.0.0.1";
        destination = "127.0.0.1";
        port = 6667;
        inbound.length = 1;
        outbound.length = 1;
      };
    };
  };
}
