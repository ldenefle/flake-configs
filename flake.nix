{
  description = "Build image";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blog = {
      url = "github:ldenefle/blog.lunef.xyz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      commonModules = [ ./common ];

      # Create a NixOS system configuration with our default customizations
      # using the given package set and some extra modules.
      mkSystem = pkgs: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit (pkgs) system;
          modules = commonModules ++ extraModules;
          specialArgs = {
            inherit inputs;
            # Use overlayed pkgs
            inherit pkgs;
            # Use overlayed lib
            inherit (pkgs) lib;
            inherit (pkgs) system;
          };
        };

      # Apply our overlays to a nixpkgs for a certain system architecture
      # and return the resulting package set.
      mkPkgs = system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowBroken = true;
          # No overlays for now
          # overlays = [
          # ];
        };

      # Get a couple handy aliases for properly customized package sets.
      legacyPackages = {
        x86_64-linux = mkPkgs "x86_64-linux";
        aarch64-linux = mkPkgs "aarch64-linux";
        armv7l-linux = mkPkgs "armv7l-linux";
      };

      mkSystemx86 = mkSystem legacyPackages.x86_64-linux;
      mkSystemarmv7l = mkSystem legacyPackages.armv7l-linux;
    in {
      nixosConfigurations = {
        odroid = mkSystemarmv7l [ ./hosts/odroid ];
        sirocco = mkSystemx86 [ ./hosts/sirocco ];
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = legacyPackages.${system};
      in {
        formatter = pkgs.nixfmt;
        devShells.default = pkgs.mkShell { buildInputs = with pkgs; [ sops packer ]; };
      }));
}

