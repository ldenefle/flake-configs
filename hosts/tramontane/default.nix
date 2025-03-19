{ config, inputs, lib, system, modulesPath, pkgs, ... }:
let
  filebrowserPort = 8080;
  immichPort = 2283;
  dnsPort = 53;
  blockyHttpPort = 4000;
in {
  imports = [ ./hardware-configuration.nix ./users.nix ];

  sops.secrets.tailscale_auth = { };
  sops.secrets.kavita_token_key = { };

  users.users.disk = {
    isSystemUser = true;
    group = "disk";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 dnsPort blockyHttpPort ];
    allowedUDPPorts = [ dnsPort ];
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

  services.resolved.enable = false;
  services.blocky = {
    enable = true;
    settings = {
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };

      ports = {
        dns = dnsPort;
        http = blockyHttpPort;
      };

      upstreams.groups.default = [ "https://one.one.one.one/dns-query" ];
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      blocking = {
        denylists = {
          #Adblocking
          ads = [
            "https://adaway.org/hosts.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://v.firebog.net/hosts/AdguardDNS.txt"
            "https://v.firebog.net/hosts/Admiral.txt"
          ];
        };
        #Configure what block categories are used
        clientGroupsBlock = { default = [ "ads" ]; };
      };
    };
  };

  programs.rust-motd = {
    enable = true;
    enableMotdInSSHD = true;
    settings = {
      banner = {
        color = "blue";
        command = with pkgs;
          "${nettools}/bin/hostname | ${figlet}/bin/figlet -f slant";
      };
      filesystems = {
        root = "/";
        tank = "/storage";
      };
      memory = { swap_pos = "beside"; };
      last_login = {
        lucas = 1;
        root = 2;
      };
    };
  };

  services.filebrowser = {
    enable = true;
    port = filebrowserPort;
    user = "disk";
    group = "disk";
    rootDir = "/storage";
  };

  services.kavita = {
    enable = true;
    tokenKeyFile = config.sops.secrets.kavita_token_key.path;
  };

  services.immich = {
    enable = true;
    port = immichPort;
  };

  users.users.immich.extraGroups = [ "video" "render" "disk" ];

  services.caddy = {
    enable = true;

    virtualHosts."files.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:${builtins.toString filebrowserPort}
    '';

    virtualHosts."stream.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:8096
    '';

    virtualHosts."photos.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:${builtins.toString immichPort}
    '';
  };

  environment.systemPackages = with pkgs; [
    filebrowser
    smartmontools
    powertop
    lm_sensors
    intel-gpu-tools
    zfs
    immich
  ];
}
