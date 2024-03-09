{
  description = "Build image";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
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

  nixConfig = {
    extra-substituters = [ "https://cache.armv7l.xyz" ];
    extra-trusted-public-keys =
      [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];
  };

  outputs = { self, nixpkgs, flake-utils, sops-nix, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        commonModules = [ sops-nix.nixosModules.sops ./common ];

        mkSystem = system: extraModules:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = commonModules ++ extraModules;
            specialArgs = { inherit inputs; inherit system;};
          };

        mkSystemx86 = mkSystem "x86_64-linux";
        mkSystemarmv7l = mkSystem "armv7l-linux";
        inherit system;
      in rec {
        nixosConfigurations = {
          odroid = mkSystemarmv7l [ ./hosts/odroid ];
          sirocco = mkSystemx86 [ ./hosts/sirocco ];
        };

        packages = {
          images.odroid =
            nixosConfigurations.odroid.config.system.build.sdImage;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            sops
            (writeScriptBin "format-all" ''
              ${fd}/bin/fd --type f nix . -X ${nixfmt}/bin/nixfmt {}
            '')
          ];
        };
      });
}

