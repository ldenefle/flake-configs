{ config, pkgs, ... }:

let
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCG93hFErx3fqBtIGQ160g9hCijpkzWe3y4x7/f315v2IlItwsyo+DJ3bEj65yfQHaWJGrkl1Dtk3ngDtBD2aDr26Dvdaoz7n7DzIIU3ztkrNfbJdoXkT+zHD4af9RXCVnpGN5HeS5csySMJClGtxuDGKqIksWzR5X0w2adZGETx3rWEApRy5fNHr04K7miPIBGbeWPkbF3FnbyeUtgzmjFw5nMmgE0+Y/cU9koXD6x3MuSg/X3PerRUqd7WZx7u/PKgrcmoB4eExMANF7BxKVYLLRacqbuDxyr5Knk/Uplzt3o9FBiP9pnIBJmIlDwRVvSUAQBvUQlo1Fj2EXfE9/n"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCW457E0WqmLfhlIEjZ+FVaiVtP3YtHPD/FewvyVLmqbv78t009eyHImkIrO0o4EWxck25EQVKucNdBIFuZ/r6pKKEEVRT/xD0cgHzzic3caTC1C2v1siQjSppyjHPQQ1tRxgSdb7CbI9FJMaVxnJv+zMQo13XgFUFR7zvW9Prjq9IJ/xm+zZUWyWAUHa1btEj7nT+Y1Jwgyz1ptPqMlJLZa3eMW2lNf2UCjJvep3YjMBt1cDytliyCBFAwLqVR9dLNkcaswdjWMIzzNdJzKdqVo7gPqWlFhiMBKS7g8cDqTno2oIXcv0gnWc7Nf76+65pyMdf4uoK8mhq1jGik2fmn"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJBOgyN+W+Nl4IIRbNBwtWKELg7hatje3ggZoue3gbV/Xh/mSH802pRQ7Fu5ipl8sqtLkuqbIwzNIpiXK+55UB1xklQG5O/bHm8X7hRCN+KNVI0NaOyxrW5hJ4kGoDan/4Xo4yjTpgWsNUZl1eZbTphzwpwAvC77j+wrbiY5koe6iugzFlsLO5esQ5hcjVxLPOvAIb6sNpFRv6DrJOI523Eo1sxIQCRV6YCN+9ic+P20K3zSB25TdZbLndvsqrSWxM0cF4LE+u/jzO/2PIg2k85bz2jKhLr4ORglav3KCnkkXwcAVV48hq/yn/IQ6TXvjSkoYSfm5g0jG0eLnRrHxQ2fnkRXfFZzEjao283yjL/VPw/i2dVGCIynH/kxfI+sAyjMGWo5aHvp9jNU5mH38vNmaI9Hdp7Vgob7PWASVATDvnszSIdehE9LLZZWhGFjgXg1Fm+GihjVSR82VhoX/uodg0niR7CV55THhzk/Lm9eMSEvtNAp6TejcxnJugULc="
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pVdsstjIlXByK3BdpdEjHNvfl+GeGGdAQxSoHi8R7gAwJkDGKfSTE8iWVedyhLOjTSW7J7+UpI/ygzq6jo0YJRToE69fr0CMglL34R2r9gVNJJvLyoi1B90ntZPIDxvi/zXtQnhkP1AifXU50iPV2MJoqXTwma7V2JG2wyNH2kvlM11OX0mmNj1vUO51kIIHjZEGTuTN/aOKVPaAodji0zhfEDrYeEAkeslUmX/SzLu+YGUmBGe9E1EYjLAvB+LVFgg4Vi2w37E0OfotolOxV7JpW05/HH09tqe1zKPS7jgplZtUbPhi+Se0AINKrvEuszkR/0zhIdMCoYXUKg3Z"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhGoDyFrVtoDcfTiNenXPPJnB+sk4WvExQaO8o33l43+ZxD7MLTY4FR6+MfFECfHL9k2UdUWVBrSv4CT3TWrqsHzzZmUWVXPP5Recnf0sZQzFLMJGK5NFoQEJVUiQYRq8EJIqUVnLmkF5qbaURTEUA/AedGadGSZieTph3rHkQ4FBmiUK0/NZS5cfyrm6c9TvfudstQAk/c+RjAtBXFnrcreoV0hVeR/X8RPV7tqhdMERMzomxt35RjVUumRrv2cyNxrZOGn69zhdR2qvz5HbrZsqOdIgt9wzA9ukqYrrt2seAUpvts57WHFmHYFWXInqsvch9MBeesl12fzZVL2Rn6W6G0YbO1PwkLyIKiQqMBjVc33vF/eYcSkExEOv9JRGh/yNdEHXo5TM4fACRUjR6v6Un294cZYe3DWcabrid/7MXpVkwJyoYFHXGrB9HArkN8cnycQbLSpQL9COnt0X0gYOni6+hoLL/kNCf0iSV02E7wvAVP/pk6su/wRo+hVo8kiTby+dEORhzIZ4OT2vimF4Sza6Tf/XdQxsVfBtcGbtyD2GqQBp2mNrVZ7r7jel7ay21jo/NTlrMblsdY/EtIZpZbWUwepDhohUlbnoKPoHqmL1z3YHvQBdGELV19YnfHBAIDsPeQglO8z+U5gvEgoGNz1pW37XnjaNPNRQudQ=="
  ];
in {
  users.users.lucas = {
    isNormalUser = true;

    home = "/home/lucas";

    extraGroups = [ "wheel" "disk" ];
    openssh.authorizedKeys.keys = keys;

    packages = with pkgs; [ htop fd silver-searcher vim ];
  };

  # Use my SSH keys for logging in as root.
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.lucas.openssh.authorizedKeys.keys;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}

