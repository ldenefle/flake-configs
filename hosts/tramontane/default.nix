{ config, inputs, lib, system, modulesPath, pkgs, ... }:

let
  spinDownMins = minutes: builtins.toString (5 * minutes);
in {
  imports = [ ./hardware-configuration.nix ];

  sops.secrets.tailscale_auth = { };

  services.udev.extraRules =
  let
    mkRule = as: lib.concatStringsSep ", " as;
    mkRules = rs: lib.concatStringsSep "\n" rs;
  in mkRules ([( mkRule [
    ''ACTION=="add|change"''
    ''SUBSYSTEM=="block"''
    ''KERNEL=="sd[a-z]"''
    ''ATTR{queue/rotational}=="1"''
    ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S ${spinDownMins 5} /dev/%k"''
  ])]);


  boot.kernelParams = [
    # Avoid downloading guc firmware that prevents i915 init
    "i915.enable_guc=2"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      intel-media-driver
      vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
    ];
  };

  powerManagement.enable = true;
  # powerManagement.powertop.enable = true;

  networking.firewall = {
    enable = true;
  };

  networking.hostName = "tramontane";

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth.path;
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    powertop
    lm_sensors
    intel-gpu-tools
  ];
}
