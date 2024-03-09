{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];
  home-manager.users.lucas = (import ./lucas);
}
