{pkgs, lib, config, ...}: let
  initrd = config.boot.initrd.keyfile-ask-password-agent;
  system = config.services.keyfile-ask-password-agent;
  config_type = lib.types.attrsOf (lib.types.submodule {
    options = {
      key-file = lib.mkOption {type = lib.types.str; description = "A path to the keyfile";};
      key-file-offset = lib.mkOption {type = lib.types.int; description = "The offset into the keyfile"; default = 0;};
      key-file-size = lib.mkOption {type = lib.types.nullOr lib.types.int; description = "The size of the keyfile"; default = null;};
      poll-interval = lib.mkOption {type = lib.types.int; description = "The interval in seconds between polls"; default = 1;};
      chain-with = lib.mkOption {type = lib.types.nullOr lib.types.str; description = "Pass the key from the keyfile through this command before sending to the daemon"; default = null;};
    };
  });
  mkAgentScriptName = (name: "systemd-${name}-keyfile-agent");
  mkAgentScript = (message-fragment: script-name: {chain-with, key-file-size, key-file, key-file-offset, poll-interval}: pkgs.writeShellScript "${script-name}" ''
        set -euo pipefail

        ASK_DIR="/run/systemd/ask-password"

        handle_unlock() {
          for f in "$ASK_DIR"/ask.*; do
            [ -e "$f" ] || continue

            local socket message
            socket=$(${pkgs.gnugrep}/bin/grep '^Socket=' "$f" | ${pkgs.coreutils}/bin/cut -d= -f2)
            message=$(${pkgs.gnugrep}/bin/grep '^Message=' "$f" | ${pkgs.coreutils}/bin/cut -d= -f2)

            if [[ "$message" == *"${message-fragment}"* && -b "${key-file}" && -n "$socket" ]]; then
              echo "Candidate keyfile ${key-file} matched! Replying..."
              (echo -n "+"; dd if="${key-file}" bs=1 skip="${builtins.toString key-file-offset}"${if (builtins.isNull key-file-size) then "" else " count=\"${builtins.toString key-file-size}\""} status=none${if (builtins.isNull chain-with) then "" else " | ${chain-with}"}) | ${pkgs.coreutils}/bin/printf "%s" $(${pkgs.coreutils}/bin/cat) | ${pkgs.socat}/bin/socat - UNIX-SENDTO:"$socket"
              ${pkgs.coreutils}/bin/rm "$f"
              return 0
            fi
          done
          return 1
        }

        while true; do
          if handle_unlock; then
            sleep ${builtins.toString poll-interval}
          fi

          ${pkgs.inotify-tools}/bin/inotifywait -e close_write,moved_to "$ASK_DIR" --timeout ${builtins.toString poll-interval} >/dev/null 2>&1 || true
        done
      '');
  mkAgentPathUnit = (message-fragment: {
    description = "Watch for password requests to inject Keyfile ${message-fragment}";
    documentation = [ "http://www.freedesktop.org/wiki/Software/systemd/PasswordAgents"];
    unitConfig.DefaultDependencies = false;
    conflicts = [ "shutdown.target" "emergency.service" ];
    before = [ "paths.target" "shutdown.target" "cryptsetup.target" "emergency.service" ];
    wantedBy = ["sysinit.target"];
    pathConfig = {
      DirectoryNotEmpty = "/run/systemd/ask-password";
      MakeDirectory = true;
    };
  }); 
  mkAgentServiceUnit = (message-fragment: options: let
   scriptName = (mkAgentScriptName message-fragment);
  in {
    description = "Automatic ${message-fragment} Keyfile Password Agent";
    documentation = [ "man:systemd-ask-password-console.service(8)" ];
    unitConfig.DefaultDependencies = false;
    conflicts = [ "emergency.service" "shutdown.target" "initrd-switch-root.target" ];
    before = [ "emergency.service" "shutdown.target" "initrd-switch-root.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${mkAgentScript message-fragment scriptName options}";
    };
  });
in {
  options.boot.initrd.keyfile-ask-password-agent = {
    enable = lib.mkEnableOption "Enable keyfile systemd-ask-password agent";
    replies = lib.mkOption {
      type = config_type;
      default = {};
      description = "A key value pair from a message fragment to a agent configuration";
    };
  };
  options.services.keyfile-ask-password-agent = {
    enable = lib.mkEnableOption "Enable keyfile systemd-ask-password agent";
    replies = lib.mkOption {
      type = config_type;
      default = {};
      description = "A key value pair from a message fragment to a agent configuration";
    };
  };
  config.boot.initrd = lib.mkIf initrd.enable {
    availableKernelModules = [ "usb_storage" "uas" "xhci_pci" "ehci_pci" ];
    systemd = {
      extraBin = {
        grep = "${pkgs.gnugrep}/bin/grep";
        socat = "${pkgs.socat}/bin/socat";
        inotifywait = "${pkgs.inotify-tools}/bin/inotifywait";
      } // (lib.mapAttrs' (message-fragment: options: let
        scriptName = (mkAgentScriptName message-fragment);
      in (lib.nameValuePair scriptName (mkAgentScript message-fragment scriptName options))) initrd.replies);
      services = lib.mapAttrs' (message-fragment: options: lib.nameValuePair "systemd-ask-password-keyfile@${message-fragment}" (mkAgentServiceUnit message-fragment options)) initrd.replies;
      paths = lib.mapAttrs' (message-fragment: options: lib.nameValuePair "systemd-ask-password-keyfile@${message-fragment}" (mkAgentPathUnit message-fragment)) initrd.replies;
    };
  };
  config.systemd = lib.mkIf system.enable {
    services = lib.mapAttrs' (message-fragment: options: lib.nameValuePair "systemd-ask-password-keyfile@${message-fragment}" (mkAgentServiceUnit message-fragment options)) system.replies;
    paths = lib.mapAttrs' (message-fragment: options: lib.nameValuePair "systemd-ask-password-keyfile@${message-fragment}" (mkAgentPathUnit message-fragment)) system.replies;
  };
}
