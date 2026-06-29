{pkgs, ...}: {
  boot.initrd.availableKernelModules = [ "usb_storage" "uas" "xhci_pci" "ehci_pci" ];
  boot.initrd.systemd = {
  extraBin = {
    bash = "${pkgs.bash}/bin/bash";
    coreutils = "${pkgs.coreutils}/bin/coreutils";
    grep = "${pkgs.gnugrep}/bin/grep";
    socat = "${pkgs.socat}/bin/socat";
    inotifywait = "${pkgs.inotify-tools}/bin/inotifywait";
  };

  services."systemd-ask-password-usb-keyfile" = {
    description = "Automatic USB Keyfile Password Agent";
    documentation = [ "man:systemd-ask-password-console.service(8)" ];
    DefaultDependencies = false;
    Conflicts = [ "emergency.service" "shutdown.target" "initrd-switch-root.target" ];
    Before = [ "emergency.service" "shutdown.target" "initrd-switch-root.target" ];
    
    serviceConfig = {
      Type = "simple";
      Environment = "PATH=/bin:/usr/bin";
      ExecStart = pkgs.writeShellScript "usb-keyfile-agent-run" ''
        set -euo pipefail
        
        ASK_DIR="/run/systemd/ask-password"
        USB_DEV="/dev/disk/by-id/usb-SanDisk_Ultra_4C531001490317105334-0:0"
        OFFSET=15376280576
        SIZE=4096

        handle_unlock() {
          for f in "$ASK_DIR"/ask.*; do
            [ -e "$f" ] || continue
            
            local socket message
            socket=$(grep '^Socket=' "$f" | cut -d= -f2)
            message=$(grep '^Message=' "$f" | cut -d= -f2)
            
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
            sleep 2
          fi

          # 2. Block until either a new ask file appears OR 2 seconds pass 
          # The 2-second timeout ensures we regularly poll for a hotplugged USB block device
          inotifywait -e close_write,moved_to "$ASK_DIR" --timeout 2 >/dev/null 2>&1 || true
        done
      '';
    };
  };
  paths."systemd-ask-password-usb-keyfile" = {
    description = "Watch for password requests to inject USB keyfile";
    documentation = [ "http://www.freedesktop.org/wiki/Software/systemd/PasswordAgents"];
    DefaultDependencies = false;
    Conflicts = [ "shutdown.target" "emergency.service" ];
    Before = [ "paths.target" "shutdown.target" "cryptsetup.target" "emergency.service" ];
    wantedBy = ["sysinit.target"]; 
    pathConfig = {
      DirectoryNotEmpty = "/run/systemd/ask-password";
      MakeDirectory = true;
    };
  };
};

}
