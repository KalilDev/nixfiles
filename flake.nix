{
  description = "Home-Manager + nixos flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-9e1f33.url = "github:nixos/nixpkgs/9e1f33d1c971ba85d7f51338bbfd7ceefb07e7c8";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-session = {
      url = "path:./hyprland-session";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-stable, home-manager, nixpkgs-9e1f33, hyprland-session, ... }: {
    nixosConfigurations = let
      overlays = [
        (final: prev: {
          stable = import nixpkgs-stable {
            inherit (final) system;
            config.allowUnfree = true;
          };
          pin-9e1f33 = import nixpkgs-9e1f33 {
            inherit (final) system;
            config.allowUnfree = true;
          };
        })
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
          hyprland-session.nixosModules.shared
          ./system/thinkprime.nix
          ./system/users/pedro-thinkprime.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import ./home/pedro-thinkprime.nix;
            home-manager.sharedModules = [
              hyprland-session.homeManagerModules.shared
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
          hyprland-session.nixosModules.shared
          ./system/virtualmachine.nix
          ./system/users/pedro-virtualmachine.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import ./home/pedro-virtualmachine.nix;
            home-manager.sharedModules = [
              hyprland-session.homeManagerModules.shared
            ];
          }
        ];
        specialArgs = { inherit inputs; inherit home-manager; };
      };
    };
  };
}
