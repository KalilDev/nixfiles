{config, lib, pkgs, ...}:
let
  # Define the JetBrains gateway environment
  # Issue https://github.com/NixOS/nixpkgs/issues/375254
  gateway-fix-client = pkgs.buildFHSEnv {
    name = "gateway";
    version = "2024.3.3";

    runScript = pkgs.writeScript "gateway-wrapper" ''
      unset JETBRAINS_CLIENT_JDK
      exec ${pkgs.jetbrains.gateway}/bin/gateway "$@"
    '';

    meta = pkgs.jetbrains.gateway.meta;
    passthru = {
      # Provide passthru to pass additional attributes if needed
      inherit (pkgs.jetbrains.gateway) meta;
    };
  };
in {
  age.secrets.spotify_password.file = ../secrets/spotify_password.age;
  imports = [
    ./software/easyeffects.nix
    ./session/sway.nix
    ./session/hyprland.nix
    ./software/alacritty.nix
    ./software/waydroid.nix
    ./software/spotifyd.nix
    ./ui/gtk.nix
    ./ui/qt.nix
    ./desktop-entries.nix
  ];
  home.packages = with pkgs; [  
    (pkgs.writeShellScriptBin "nix-shell" ''
    has_run=0

    for arg in "$@"; do
      if [[ "$arg" == "--run" || "$arg" == "-r" ]]; then
        has_run=1
        break
      fi
    done

    if [[ $has_run -eq 1 ]]; then
      exec ${pkgs.nix}/bin/nix-shell "$@"
    else
      exec ${pkgs.nix}/bin/nix-shell --run "''${SHELL:-zsh}" "$@"
    fi
  '')
    (bottles.override {removeWarningPopup = true;})
    nautilus
    vlc
    tree
    fastfetch
    pwvucontrol
    go
    qbittorrent
    # fira-code
    # fira-code-symbols
    font-awesome
    # liberation_ttf
    # mplus-outline-fonts.githubRelease
    # nerdfonts
    noto-fonts
    noto-fonts-color-emoji
    # proggyfonts
    htop
    killall
    ghidra-bin
    gparted
    discord
    jetbrains.jdk
    jetbrains.clion
    jetbrains.gateway
    gnumake
    # Gtk-launch
    gtk3
    # (pkgs.upstream-de09e1.jetbrains.gateway.overrideAttrs {
    #   extraBuildInputs = [ glib ];
    # })
    jetbrains.ruby-mine
    jetbrains.rust-rover
    jetbrains.goland
    jetbrains.datagrip
    jetbrains.pycharm
    scrcpy
    stremio-linux-shell
    jq
    loupe
    google-chrome
    telegram-desktop
    wf-recorder
    ffmpeg
    # Audio
    musescore
    ardour
    audacity
    qpwgraph
    wineWowPackages.waylandFull
    yabridge
    yabridgectl
    reaper
    # VST
    noise-repellent
    # Music player
    gapless
    # Utils
    gimp
    python3
    cloc
    qpdf
    zip
    unzip
    unrar
    strace
    usbutils
    protonup-ng
    protonup-qt
    pciutils
    pdfarranger
    kdePackages.okular
    gnome-text-editor
    obs-studio
    nmap
    mpv
    loupe
    inkscape
    jq
    glib
    p7zip
    bc
    binutils
  ];
  home.sessionVariables = rec {
    EDITOR = "${pkgs.vim}/bin/vim";
  };
  systemd.user.sessionVariables = rec {
    EDITOR = "${pkgs.vim}/bin/vim";
    XDG_DESKTOP_DIR = "$HOME/Desktop";
    XDG_DOWNLOAD_DIR = "$HOME/Downloads";
    XDG_DOCUMENTS_DIR = "$HOME/Documents";
    XDG_MUSIC_DIR = "$HOME/Media/Musics";
    XDG_PICTURES_DIR = "$HOME/Media/Images";
    XDG_VIDEOS_DIR = "$HOME/Media/Videos";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CONFIG_HOME = "$HOME/.local/etc";
    XDG_CACHE_HOME = "$HOME/.local/tmp";
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = "$PATH:$HOME/.local/bin";
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings.user.name = "KalilDev";
    settings.user.email = "KalilDev@users.noreply.github.com";
    package = pkgs.gitFull;
  };
  home.stateVersion = "24.11";
  xdg.portal.enable = true;
  programs.zsh = {
    enable = true;
    history = {
      append = true;
      share = false;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [];
      theme = "agnoster";
    };
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.rofi = {
    enable = true;
    package = pkgs.rofi; # was rofi-wayland
  };
  services.kdeconnect.enable = true;
  services.blueman-applet.enable = true;
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
  };
  
  

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
     dart-code.dart-code
     dart-code.flutter
     ms-azuretools.vscode-docker
     firefox-devtools.vscode-firefox-debug
     github.github-vscode-theme
#     sidthesloth.html5-boilerplate
     yzhang.markdown-all-in-one
     mkhl.direnv
#      dracula-theme.theme-dracula
#      vscodevim.vim
#      yzhang.markdown-all-in-one
    ];
  };
}
