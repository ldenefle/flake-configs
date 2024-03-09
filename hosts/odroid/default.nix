{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix"
  ];

  boot.consoleLogLevel = 7;
  nixpkgs.config.allowBroken = true;
  # boot.kernelPackages = pkgs.linuxPackages_hardkernel_latest;
}
