{config, lib, pkgs, ...}: {
#  xdg.configFile."gtk-3.0/bookmarks".force = true;
#  xdg.configFile."gtk-3.0/bookmarks".text = ''
#  '';

  gtk = {
    enable = true;
    colorScheme = "dark";
    gtk3.enable = true;
    gtk3.bookmarks = [
      "file:///home/pedro/Desktop"
      "file:///home/pedro/Downloads"
      "file:///home/pedro/Documents"
      "file:///home/pedro/Media/Musics"
      "file:///home/pedro/Media/Images"
      "file:///home/pedro/Media/Videos"
    ];
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    gtk4.enable = false;
    gtk4.extraConfig = {
      AdwStyleManager.color-scheme = "prefer-dark";
    };
  };
  xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
  ];
  xdg.configFile."gtk-4.0/settings.ini" = {
    text = "[Settings]
gtk-application-prefer-dark-theme=true
gtk-interface-color-scheme=2

[AdwStyleManager]
color-scheme=prefer-dark

[HdyStyleManager]
color-scheme=prefer-dark
";
  };
#  dconf.settings = {
#  "org/gnome/desktop/interface" = {
#    color-scheme = "prefer-dark";
#  };
# };
}
