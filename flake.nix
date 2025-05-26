{
  description = "Home-Manager + nixos flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-stable, home-manager, ... }: {
    nixosConfigurations = let
      overlays = [
        (final: prev: {
          stable = import nixpkgs-stable {
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
          ./system/thinkprime.nix
          ./system/users/pedro-thinkprime.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import ./home/pedro-thinkprime.nix;
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
          ./system/virtualmachine.nix
          ./system/users/pedro-virtualmachine.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import ./home/pedro-virtualmachine.nix;
          }
        ];
        specialArgs = { inherit inputs; inherit home-manager; };
      };
    };
  };
}
