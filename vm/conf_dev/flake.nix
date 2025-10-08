{
  description = "Minimal NixOS VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: 
    let
      modulesPath = "${nixpkgs}/nixos/modules";
    in 
    {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
          (import "${home-manager}/nixos")
          (import "${modulesPath}/virtualisation/qemu-vm.nix")
          # ./vm-conf.nix
          ./minimal-claude.nix
        ];
    };
  };
}
