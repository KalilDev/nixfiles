{lib, pkgs, config, ...}: {
 services.spotifyd = {
   enable = true;
   settings =
     {
       global = {
         username = "kalilgamer0";
         password_cmd = "cat ${config.age.secrets.cloudflare_tunnel.path}";
       };
     }
   ;
 }
}
