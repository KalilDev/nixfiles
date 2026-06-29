{config, lib, pkgs, ...}: {
  custom.waydroid-desktops = {
    hide = true;
    whitelist = ["com.songsterr"];
  };
#  xdg.desktopEntries."com.stremio.Stremio.desktop" = {
#    exec="sh -c \"stremio --enable-features=UseOzonePlatform --ozone-platform=wayland -o '%u'\"";
#    name = "Stremio";
#    comment = "Freedom To Stream";
#    icon = "com.stremio.Stremio";
#    terminal = false;
#    startupNotify = true;
#    mimeType = ["x-scheme-handler/stremio"];
#    type = "Application";
#    categories = ["Utility" "AudioVideo" "Video" "Player"];
#    settings = {
#     Keywords = "Stremio;Media;Play;";
#    };
#  };
}
