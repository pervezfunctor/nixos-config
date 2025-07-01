# flake.nix
{
  description = "NixOS Backup Box";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        nixosConfigurations.backup-box = pkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/backup-box/configuration.nix
          ];
        };
      });
}
