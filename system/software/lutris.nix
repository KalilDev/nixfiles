{config, lib, pkgs, ...}: {
  # Esync, also set on users
  systemd.settings.Manager.DefaultLimitNOFILE=524288;
  environment.systemPackages = (with pkgs; [
    (lutris.override {
       extraPkgs = pkgs: [
         mangohud
         pkgs.pin-9e1f33.gamescope
       ];
    })
  ]);
}
