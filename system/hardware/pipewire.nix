{config, lib, pkgs, ...}: {
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    extraConfig = lib.mkIf (config.specialisation != {}) {
      pipewire."99-wine.conf" = {
        "context.properties" = {
          "default.clock.min-quantum" = 4096;
          "default.clock.max-quantum" = 4096;
          "default.clock.quantum" = 4096;
        };
      };
    };
  };

  specialisation = {
    realtime = {
      configuration = {
	
      };
    };
  };
}
