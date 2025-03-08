{pkgs, ...}:
let
  louisKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdECRQkiTNYSzdphl3lw1n0mEmL5YnwZJ691aqKYMVx"
  ];
in {
  users.users.louis = {
    isNormalUser = true;
    createHome = true;

    home = "/home/louis";

    extraGroups = [ "disk" ];
    openssh.authorizedKeys.keys = louisKeys;

    packages = with pkgs; [ vim ];
  };
}
