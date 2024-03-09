{ inputs, system, modulesPath, ... }:

let
  blog = inputs.blog.packages."${system}".default;
in {
  imports = [
    "${modulesPath}/virtualisation/digital-ocean-image.nix"
  ];

  services.radicale = {
    enable = true;
    settings = {
      server = { hosts = [ "0.0.0.0:5232" ]; };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "/etc/radicale/users";
        htpasswd_encryption = "md5";
      };
      storage = { filesystem_folder = "/var/lib/radicale/collections"; };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."blog.lunef.xyz".extraConfig = ''
      encode gzip
      file_server
      root * ${blog}
    '';

    virtualHosts."calendar.lunef.xyz".extraConfig = ''
      reverse_proxy localhost:5232
    '';

    virtualHosts."stuff.lunef.xyz".extraConfig = ''
      file_server browse
      root * /media/
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
}
