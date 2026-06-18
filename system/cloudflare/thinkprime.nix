{config, lib, pkgs, ...}: {
  environment.systemPackages = [pkgs.cloudflared];
  services.cloudflared = {
    enable = true;
    tunnels = {
      "37110799-8c5d-4b9a-88a0-e485e29157db" = {
        credentialsFile = config.age.secrets.cloudflare_tunnel.path;
        ingress = {
          "xn--qei.kalil.tech" = {
            service = "http://localhost:9999";
          };
        };
        default = "http_status:404";
      };
    };
  };
}
