{ config, inputs, lib, system, modulesPath, ... }:

let
in {
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  networking.hostName = "tramontane";
}
