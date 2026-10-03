{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ../configuration.nix
  ];
  services.xserver.enable = true;
  services.envfs.enable = true;
  services.tailscale.enable = true;
  myModules.primaryUser = "ben";
  services.paseo.listenAddress = lib.mkForce "100.85.161.82";
  age.secrets.paseo-password-environment.file =
    lib.mkForce ../secrets/paseo-password-environment.bencbox.age;
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/ben/.ssh/id_ed25519"
  ];
  systemd.services.paseo = {
    after = ["tailscaled.service"];
    wants = ["tailscaled.service"];
    environment = {
      HOME = "/home/ben";
      LOGNAME = "ben";
      USER = "ben";
    };
    serviceConfig.WorkingDirectory = "/home/ben";
    preStart = lib.mkBefore ''
      ${pkgs.coreutils}/bin/timeout 30s ${pkgs.tailscale}/bin/tailscale wait
      ${pkgs.tailscale}/bin/tailscale ip --assert=${lib.escapeShellArg config.services.paseo.listenAddress}
    '';
  };
  environment.systemPackages = with pkgs; [
    sublime3
    vlc
    bat
  ];
  myModules.desktop.enable = false;
  myModules.googleMessages.enable = false;
  myModules.taffybar.enable = false;
  myModules.plasma.enable = false;
  imalison.nixOverlay.enable = false;
  myModules.wsl.enable = true;

  networking.hostName = "bencbox";
  myModules.hostIdentity = {
    emoticon = "📦";
    tmux.background = "#b45309";
  };

  wsl.defaultUser = "ben";
  system.stateVersion = "22.05";

  home-manager.sharedModules = [
    {
      home.stateVersion = "22.05";
    }
  ];

  users.users.ben = {
    extraGroups =
      [
        "audio"
        "adbusers"
        "disk"
        "docker"
        "networkmanager"
        "openrazer"
        "plugdev"
        "syncthing"
        "systemd-journal"
        "video"
      ]
      ++ ["wheel"];
  };
}
