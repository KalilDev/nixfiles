{ config, lib, pkgs, nixpkgs, ...}: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
      ./amd/ryzen.nix
      ./amd/amdgpu.nix
      ./amd/lact.nix
      ./hardware/fprintd.nix
      ./boot/btrfs.nix
      ./boot/initrd-systemd.nix
      ./boot/systemd-boot.nix
      ./boot/plymouth.nix
      ./kernel/rt_latest.nix
      ./virtualisation/waydroid.nix
      ./_standard.nix
      ./cloudflare/thinkprime.nix
      ./luks_unlock.nix
  ];

  age.secrets.cloudflare_tunnel.file = ../secrets/cloudflare_tunnel.age;

  hardware.firmware = [ pkgs.linux-firmware ];
  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usbhid" "uas" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "dm_mod" "cryptd" "nvme" ];
  boot.kernelModules = [ "dm-snapshot"  "thinkpad-acpi" "kvm-amd" ];
  boot.kernelParams = [ "thinkpad_acpi.fan_control=1" "boot.shell_on_fail" ];
  boot.resumeDevice = "/dev/vg_wd_blue_luks/swap";
  boot.initrd.luks.devices."wd_blue_luks" = {
    device = "/dev/disk/by-uuid/052a7220-479f-4c53-b6d4-80e3dcaa6c24";
    preLVM = true;
    #keyFile = "/dev/disk/by-id/usb-SanDisk_Ultra_4C531001490317105334-0:0";
    #keyFileOffset = 15376280576;
    #keyFileSize = 4096;
    #keyFileTimeout = 15;
  };
  services.fwupd.enable = true;
  boot.initrd.keyfile-ask-password-agent = {
    enable = true;
    replies."wd_blue_luks" = {
      key-file = "/dev/disk/by-id/usb-SanDisk_Ultra_4C531001490317105334-0:0";
      key-file-offset = 15376280576;
      key-file-size = 32;
      poll-interval = 1;
    };  
  };
  services.keyfile-ask-password-agent = {
    enable = true;
    replies."wd_blue_luks" = {
      key-file = "/dev/disk/by-id/usb-SanDisk_Ultra_4C531001490317105334-0:0";
      key-file-offset = 15376280576;
      key-file-size = 32;
      poll-interval = 1;
    };  
  };



  # workaround for t14 backlight  
  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
'';

    # Thinkfan
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
  services.thinkfan = {
    enable = true;
    sensors = [
      {
        type = "hwmon";
        query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp1_input";
      }
    ];
    
    
    levels = [
      ["level auto" 0 85]
      [6 85 92]
      [7 92 32767]
    ];
  };

  fileSystems."/" = {
    device = "/dev/vg_wd_blue_luks/root";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" ];
  };

  fileSystems."/home" = {
    device = "/dev/vg_wd_blue_luks/root";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  fileSystems."/flake" = {
    device = "/dev/vg_wd_blue_luks/root";
    fsType = "btrfs";
    options = [ "subvol=@flake" "compress=zstd" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/4D99-5856";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    {
      device = "/dev/vg_wd_blue_luks/swap";
    }
  ];
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "thinkprime";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
