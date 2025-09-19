{
  description = "NixOS Offline Auto Installer";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { config, self', system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default = pkgs.mkShell {
          packages = [ self'.formatter ];
        };

        packages = {
          default = config.packages.installer-iso;
          installer-iso = inputs.self.nixosConfigurations.installer.config.system.build.isoImage;

          install-demo = pkgs.writeShellScript "install-demo" ''
            set -euo pipefail
            disk=root.img
            if [ ! -f "$disk" ]; then
              echo "Creating harddisk image root.img"
              ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$disk" 20G
            fi
            ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -cpu host \
              -enable-kvm \
              -m 2G \
              -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
              -cdrom ${config.packages.installer-iso}/iso/*.iso \
              -hda "$disk"
          '';
        };

        treefmt = {
          projectRootFile = "flake.lock";
          programs = {
            deadnix.enable = true;
            nixfmt.enable = true;
            shfmt.enable = true;
            statix.enable = true;
            prettier.enable = true;
          };
        };
      };
      flake = {
        nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./installer.nix ];
        };
        nixosConfigurations.installed = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./configuration/configuration.nix ];
        };
      };
    };
}
