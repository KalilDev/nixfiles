{
  description = "Home-Manager + nixos flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    nixosConfigurations = {
      thinkprime = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./system/thinkprime.nix
          "./system/users/thinkprime@pedro.nix"
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pedro = import "./home/pedro@thinkprime.nix";
          }
        ];
        specialArgs = { inherit home-manager nixpkgs-unstable; };
      };
    };
  };
}
