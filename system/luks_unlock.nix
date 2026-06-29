{pkgs, ...}: {
  boot.initrd.availableKernelModules = [ "usb_storage" "uas" "xhci_pci" "ehci_pci" ];
  boot.initrd.systemd = {
  extraBin = {
    bash = "${pkgs.bash}/bin/bash";
    coreutils = "${pkgs.coreutils}/bin/coreutils";
    grep = "${pkgs.gnugrep}/bin/grep";
    socat = "${pkgs.socat}/bin/socat";
    inotifywait = "${pkgs.inotify-tools}/bin/inotifywait";
    systemd-ask-password-usb-keyfile-agent = pkgs.writeShellScript "usb-keyfile-agent-run" ''
        set -euo pipefail

        ASK_DIR="/run/systemd/ask-password"
        USB_DEV="/dev/disk/by-id/usb-SanDisk_Ultra_4C531001490317105334-0:0"
        OFFSET=15376280576
        SIZE=32
        POLL_TIMEOUT=1

        handle_unlock() {
          for f in "$ASK_DIR"/ask.*; do
            [ -e "$f" ] || continue

            local socket message
            socket=$(grep '^Socket=' "$f" | cut -d= -f2)
            message=$(grep '^Id=' "$f" | cut -d= -f2)

            if [[ "$message" == *"wd_blue_luks"* && -b "$USB_DEV" && -n "$socket" ]]; then
              echo "USB key detected! Automatically unlocking volume..."
              (echo -n "+"; dd if="$USB_DEV" bs=1 skip="$OFFSET" count="$SIZE" status=none) | socat - UNIX-SENDTO:"$socket"
              return 0
            fi
          done
          return 1
        }

        # Main persistent daemon loop
        while true; do
          # 1. Attempt to unlock immediately if the prompt and device already exist
          if handle_unlock; then
            # Sleep briefly to avoid hammering if systemd takes a second to clean up the ask file
            sleep $POLL_TIMEOUT
          fi

          # 2. Block until either a new ask file appears OR 2 seconds pass
          # The 2-second timeout ensures we regularly poll for a hotplugged USB block device
          inotifywait -e close_write,moved_to "$ASK_DIR" --timeout $POLL_TIMEOUT >/dev/null 2>&1 || true
        done
      '';
  };

  services."systemd-ask-password-usb-keyfile" = {
    description = "Automatic USB Keyfile Password Agent";
    documentation = [ "man:systemd-ask-password-console.service(8)" ];
    unitConfig.DefaultDependencies = false;
    conflicts = [ "emergency.service" "shutdown.target" "initrd-switch-root.target" ];
    before = [ "emergency.service" "shutdown.target" "initrd-switch-root.target" ];
    
    serviceConfig = {
      Environment = "PATH=/bin:/usr/bin";
      Type = "simple";
      ExecStart = "/bin/systemd-ask-password-usb-keyfile-agent";
    };
  };
  paths."systemd-ask-password-usb-keyfile" = {
    description = "Watch for password requests to inject USB keyfile";
    documentation = [ "http://www.freedesktop.org/wiki/Software/systemd/PasswordAgents"];
    unitConfig.DefaultDependencies = false;
    conflicts = [ "shutdown.target" "emergency.service" ];
    before = [ "paths.target" "shutdown.target" "cryptsetup.target" "emergency.service" ];
    wantedBy = ["sysinit.target"]; 
    pathConfig = {
      DirectoryNotEmpty = "/run/systemd/ask-password";
      MakeDirectory = true;
    };
  };
};

}
