{
  description = "Home-Manager + nixos flake";

  inputs = {
    nixpkgs-stable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1.1005841";
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1.1012902";
    nixpkgs-9e1f33.url = "github:nixos/nixpkgs/9e1f33d1c971ba85d7f51338bbfd7ceefb07e7c8";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.2605.6814";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wlr-hdr = {
      url = "github:njdom24/wlr-hdr-cal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ nixpkgs, nixpkgs-stable, musnix, home-manager, nixpkgs-9e1f33, agenix, wlr-hdr, ... }: {
    nixosConfigurations = let
      overlays = [
        (final: prev: {
          wlr-hdr-cal = wlr-hdr.wlr-hdr-cal.packages.${prev.stdenv.hostPlatform.system}.default;
        })
        (final: prev: {
          jetbrains = prev.jetbrains // {
            gateway = let
              unwrapped = prev.jetbrains.gateway;
              wrapperName = "gateway";
              desktopItem = prev.makeDesktopItem {
                name = "jetbrains-gateway";
                exec = wrapperName; # This must match the name of the wrapper script in `buildFHSEnv`
                icon = "${unwrapped}/share/icons/hicolor/256x256/apps/jetbrains-gateway.png"; # adjust if needed
                comment = "JetBrains Gateway";
                desktopName = "JetBrains Gateway";
                categories = [ "Development" "IDE" ];
                terminal = false;
              };
            in prev.buildFHSEnv {
              name = wrapperName;
              inherit (unwrapped) version;

              runScript = prev.writeScript "gateway-wrapper" ''
                unset JETBRAINS_CLIENT_JDK
                exec ${unwrapped}/bin/gateway "$@"
              '';

              meta = unwrapped.meta;

              passthru = {
                inherit unwrapped;
              };

              extraInstallCommands = ''
                mkdir -p $out/share/applications
                cp ${desktopItem}/share/applications/* $out/share/applications/
              '';
            };
          };
        })
        (final: prev: let pin-9e1f33 = import nixpkgs-9e1f33 {
            inherit (final) system;
            config.allowUnfree = true;
          }; in {
          stable = import nixpkgs-stable {
            inherit (final) system;
            config.allowUnfree = true;
          };
          #gamescope = pin-9e1f33.gamescope;
        })
        (final: prev: {
          xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (old: {
            patches = [ ./patches/00-remote-desktop.patch ];
            buildInputs = old.buildInputs ++ [prev.libxkbcommon];
            nativeBuildInputs = old.nativeBuildInputs ++ [prev.libxkbcommon];
          });
        })
	#(final: prev: {
        #  wlroots_0_20 = prev.wlroots.overrideAttrs (old: {
        #    version = "0.20.0";
        #    src = prev.fetchFromGitLab {
        #      domain = "gitlab.freedesktop.org";
        #      owner = "wlroots";
        #      repo = "wlroots";
        #      rev = "0166fd9eb778761295ea14fdff0515ada1a1cb17";
        #      sha256 = "sha256-2FK6FGRpgf/YYqwJST0LVA/pnNRSUDrfrrp6mSwA0Fk=";
        #    };
        #  });
	#})
	#(final: prev: {
	#  sway-unwrapped = prev.sway-unwrapped.overrideAttrs (oldAttrs: {
        #    src = prev.fetchFromGitHub {
        #      owner = "swaywm";
        #      repo = "sway";
        #      rev = "73c244fb4807a29c6599d42c15e8a8759225b2d6";
        #      sha256 = "sha256-P2w1oRVUNBWajt8jZOxPXvBE29urbrhtORy+lfYqnF8=";
        #    };
	#    buildInputs = (prev.lib.filter (dep: dep.name != "wlroots") oldAttrs.buildInputs) ++ [ prev.wlroots_0_20 ];
        #  });
	#})
      ];
    in {
      thinkprime = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            nixpkgs = {
              inherit overlays;
              config.allowUnfree = true;
            };
          })
          #hyprland-session.nixosModules.shared
          ./system/thinkprime.nix
          ./system/users/pedro-thinkprime.nix
          musnix.nixosModules.musnix
          ./system-musnix/thinkprime.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import ./home/pedro-thinkprime.nix;
            home-manager.sharedModules = [
              agenix.homeManagerModules.default
              #hyprland-session.homeManagerModules.shared
            ];
          }
        ];
        specialArgs = { inherit inputs; inherit home-manager; };
      };

      virtualmachine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            nixpkgs = {
              inherit overlays;
              config.allowUnfree = true;
            };
          })
          #hyprland-session.nixosModules.shared
          ./system/virtualmachine.nix
          ./system/users/pedro-virtualmachine.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import ./home/pedro-virtualmachine.nix;
            home-manager.sharedModules = [
              #hyprland-session.homeManagerModules.shared
            ];
          }
        ];
        specialArgs = { inherit inputs; inherit home-manager; };
      };
    };
  };
}
