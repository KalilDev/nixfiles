{config, lib, pkgs, ...}: {
    import = [
        ./etc/appimage.nix
        ./etc/firewall.nix
        ./etc/gaming.nix
        ./etc/i18n.nix
        ./etc/nix.nix
        ./etc/ssh.nix
        ./firewall/cities_skylines.nix
        ./firewall/kde_connect.nix
        ./hardware/adb.nix
        ./hardware/bluetooth.nix
        ./hardware/libinput.nix
        ./hardware/networkmanager.nix
        ./hardware/pipewire.nix
        ./hardware/upower.nix
        ./session/sway.nix
        ./software/firefox.nix
        ./software/greetd.nix
        ./software/lutris.nix
        ./software/steam.nix
        ./software/tailscale.nix
        ./software/utils.nix
        ./software/zsh.nix
        ./virtualisation/docker.nix
        ./virtualisation/virtd.nix
    ]
}