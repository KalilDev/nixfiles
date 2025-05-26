{config, lib, pkgs, ...}: {
  environment.systemPackages = [ pkgs.virtiofsd ];
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  };
  virtualisation.spiceUSBRedirection.enable = true;
}