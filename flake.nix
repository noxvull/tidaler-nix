{
  description = "TIDAL Downloader (fork of tidal-dl-ng)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      callTidaler = {enableGui ? false}:
        pkgs.callPackage ./default.nix {
          pythonPackages = pkgs.python313Packages;
          inherit enableGui;
        };
    in {
      packages = {
        default = callTidaler {enableGui = false;};
        tidaler-gui = callTidaler {enableGui = true;};
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.poetry
          pkgs.ffmpeg
          (pkgs.python313.withPackages (ps: (callTidaler {enableGui = true;}).dependencies))
        ];
      };
    }))
    // {
      homeModules.default = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.programs.tidaler;
      in {
        options.programs.tidaler = {
          enable = lib.mkEnableOption "TIDAL Downloader CLI/GUI framework";
          gui = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to build and install with PySide6 GUI capabilities.";
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = [
            (
              if cfg.gui
              then self.packages.${pkgs.system}.tidaler-gui
              else self.packages.${pkgs.system}.default
            )
          ];
        };
      };
    };
}
