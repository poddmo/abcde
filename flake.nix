{
  description = "abcde - A Better CD Encoder (poddmo fork)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # abcde is Linux-only (CD ripping).
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (
        system:
        let
          abcde = (pkgsFor system).callPackage ./nixos/package.nix { };
        in
        {
          inherit abcde;
          default = abcde;
        }
      );

      nixosModules = rec {
        abcde = import ./nixos/module.nix;
        default = abcde;
      };

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
