{ config, inputs, lib, system, modulesPath, pkgs, ... }:
let
  immichPort = 2283;
  dnsPort = 53;
  blockyHttpPort = 4000;
  httpBinPort = 8000;
in {
  imports = [ ./hardware-configuration.nix ./users.nix ];

  sops.secrets.tailscale_auth = { };
  sops.secrets.duckdns_token = { };

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
    group = "disk";
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth.path;
  };

  services.duckdns = {
    enable = true;
    tokenFile = config.sops.secrets.duckdns_token.path;
    domains = [
      "lunef"
    ];
  };

  services.resolved.enable = false;

  # services.localtimed.enable = true;
  # time.timeZone = "Europe/London";

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

  services.immich = {
    enable = true;
    port = immichPort;
    user = "immich";
    mediaLocation = "/storage/immich";
  };

  systemd.services.postgresql.postStart = lib.mkAfter ''
    $PSQL -tA -c "ALTER EXTENSION vectors OWNER TO immich;" immich || true
  '';

  services.go-httpbin = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = httpBinPort;
      ALLOWED_REDIRECT_DOMAINS = "httpbin.lunef.xyz,ifconfig.me";
    };
  };

  systemd.tmpfiles.rules = [
    "Z /storage/immich - immich immich -"
  ];

  users.users.immich.extraGroups = [ "video" "render" "disk" ];
  users.users.jellyfin.extraGroups = [ "video" "render" "disk" ];

  services.caddy = {
    enable = true;

    virtualHosts."stream.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:8096
    '';

    virtualHosts."photos.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:${builtins.toString immichPort}
    '';

    virtualHosts."httpbin.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:${builtins.toString httpBinPort}
    '';

    virtualHosts."radio.lunef.xyz".extraConfig = ''
      reverse_proxy bise:8000 {
        flush_interval -1
        transport http {
          read_timeout 0
        }
      }
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
    immich-go
  ];
}
