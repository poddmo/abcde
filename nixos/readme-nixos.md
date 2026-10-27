# abcde on NixOS

A [Nix flake](https://nixos.wiki/wiki/Flakes) is provided that packages this fork of
abcde and wires up all the runtime dependencies for you. It exposes:

- `packages.<system>.default` (aka `abcde`) — the abcde package, built from `nixos/package.nix`
- `nixosModules.default` (aka `abcde`) — a NixOS module (`programs.abcde`), defined in `nixos/module.nix`

Supported systems: `x86_64-linux` and `aarch64-linux` (abcde rips CDs, so it is Linux-only).

## Run it directly without installing

```
nix run github:poddmo/abcde
```

## Use the NixOS module (recommended)

Add the input to your `flake.nix`:

```nix
inputs = {
  abcde = {
    url = "github:poddmo/abcde";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Import the module and enable it in your configuration:

```nix
imports = [
  inputs.abcde.nixosModules.default
];

programs.abcde = {
  enable = true;

  # Users can still override per-account via ~/.abcde.conf.
  settings = {
    OUTPUTTYPE = "flac";
    OUTPUTDIR = "/home/you/Music";
    MAXPROCS = 2;

    
    EJECTCD = true;
    PADTRACKS = false;
  };
  extraConfig = ''
    munge_simplify_punctuation () {
        sed -e "s/\xe2\x80\x99/'/g" -e 's/\r//g'
    }
  '';
};
```

## Just install the package

Or add the package and configure abcde the traditional way with `~/.abcde.conf`:

```nix
environment.systemPackages = [
  inputs.abcde.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```
