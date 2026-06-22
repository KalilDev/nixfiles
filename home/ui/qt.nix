{config, lib, pkgs, ...}: {
  # Enforce the platform theme and style override
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}
