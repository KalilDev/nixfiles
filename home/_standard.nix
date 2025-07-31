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
  imports = [
    ./software/easyeffects.nix
    ./session/sway.nix
    ./session/hyprland.nix
    ./software/alacritty.nix
  ];
  home.packages = with pkgs; [
    vlc
    tree
    neofetch
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
    noto-fonts-emoji
    # proggyfonts
    htop
    killall
    nautilus
    ghidra-bin
    gparted
    discord
    jetbrains.jdk
    jetbrains.clion
    jetbrains.gateway
    # (pkgs.upstream-de09e1.jetbrains.gateway.overrideAttrs {
    #   extraBuildInputs = [ glib ];
    # })
    jetbrains.ruby-mine
    jetbrains.rust-rover
    jetbrains.goland
    jetbrains.pycharm-professional
    scrcpy
    stremio
    musescore
  ];
  home.sessionVariables = rec {
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
    userName = "KalilDev";
    userEmail = "KalilDev@users.noreply.github.com";
    package = pkgs.gitFull;
  };
  home.stateVersion = "24.11";
  xdg.portal = {
    enable = true;
#    config.common.default = ["wlr"];
#    extraPortals = [
#      pkgs.xdg-desktop-portal-wlr
#    ];
  };
  programs.zsh = {
    enable = true;
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
    package = pkgs.rofi-wayland;
  };
  services.kdeconnect.enable = true;
  services.blueman-applet.enable = true;
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };
  

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
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
