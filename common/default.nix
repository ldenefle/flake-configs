{ inputs, ... }:

{
  imports = [ ./users ./sops-nix.nix inputs.sops-nix.nixosModules.sops ];

  # Pin the state version
  system.stateVersion = "23.11";

  # Clean /tmp on boot.
  boot.tmp.cleanOnBoot = true;

  #  Automatically optimize the Nix store to save space
  # by hard-linking identical files together. These savings
  # add up.
  nix.settings.auto-optimise-store = true;

  #  Limit the systemd journal to 100 MB of disk or the
  # last 7 days of logs, whichever happens first.
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  # Use systemd-resolved for DNS lookups, but disable
  # its dnssec support because it is kinda broken in
  # surprising ways.
  services.resolved = {
    enable = true;
    dnssec = "false";
  };
}
