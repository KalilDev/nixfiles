let
  pedro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhw4dFAmUgPtkdbEcgoJD9OwZ+Hhz0qSRquewUA3bpf pedro@thinkpad";
  users = [ pedro ];
  
  thinkprime = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgd6e9wyQYS3lAmOYCvFUmPuk3XxVkMewgWONMGn0yg thinkprime";
  systems = [ thinkprime ];
in {
  "cloudflare_tunnel.age".publicKeys = systems ++ [pedro];
  "spotify_password.age".publicKeys = [pedro];
}
