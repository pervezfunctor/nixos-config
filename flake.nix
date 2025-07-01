{
  description = "NixOS Backup";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      backup-box = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/backup-box/configuration.nix ];
      };
    };
  };
}
