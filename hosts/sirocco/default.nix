{ config, inputs, lib, system, modulesPath, ... }:

let
  blog = inputs.blog.packages."${system}".default;
  radicalePort = 5232;
  radicalePort' = builtins.toString radicalePort;
  radicaleStorageDir = "/var/lib/radicale/collections";
  vaultwardenPort = 8222;
  vaultwardenPort' = builtins.toString vaultwardenPort;
  vaultwardenBackupDir = "/var/backup/vaultwarden";
  restrictPerms = user: {
    mode = "0440";
    owner = config.users.users."${user}".name;
    group = config.users.users."${user}".group;
  };
in {
  imports = [ "${modulesPath}/virtualisation/digital-ocean-image.nix" ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.stuff_auth = (restrictPerms "caddy");
  sops.secrets.radicale_auth = (restrictPerms "radicale");
  sops.secrets.vaultwarden = (restrictPerms "vaultwarden");
  sops.secrets.tailscale_auth = { };
  sops.secrets.tarsnap_auth = { };

  services.radicale = {
    enable = true;
    settings = {
      server = { hosts = [ "0.0.0.0:${radicalePort'}" ]; };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets.radicale_auth.path;
        htpasswd_encryption = "md5";
      };
      storage = { filesystem_folder = radicaleStorageDir; };
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth.path;
  };

  services.vaultwarden = {
    enable = true;
    backupDir = vaultwardenBackupDir;
    config = {
      ROCKET_ADDRESS = "::1"; # default to localhost
      ROCKET_PORT = vaultwardenPort;
      SIGNUPS_ALLOWED = false;
      DOMAIN = "https://pass.lunef.xyz";
      EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "ssh-key-vault-item,ssh-agent";
    };
    environmentFile = config.sops.secrets.vaultwarden.path;
  };

  services.tarsnap = {
    enable = true;
    keyfile = config.sops.secrets.tarsnap_auth.path;
    archives = {
      vaultwarden = {
        directories = [ vaultwardenBackupDir ];
        period = "weekly";
      };
      radicale = {
        directories = [ radicaleStorageDir ];
        period = "weekly";
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."blog.lunef.xyz".extraConfig = ''
      encode gzip
      file_server
      root * ${blog}
    '';

    virtualHosts."pass.lunef.xyz".extraConfig = ''
      encode gzip
      reverse_proxy localhost:${vaultwardenPort'}
    '';

    virtualHosts."calendar.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:${radicalePort'}
    '';

    virtualHosts."stuff.lunef.xyz".extraConfig = ''
      file_server browse
      root * /media/
      basicauth {
        import ${config.sops.secrets.stuff_auth.path}
      }
    '';

  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  networking.hostName = "sirocco";
}
