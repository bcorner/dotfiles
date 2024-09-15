{ lib, pkgs, config, inputs, forEachUser, ... }:
{
  imports = [
    ../configuration.nix
  ];
  services.xserver.enable = true;
  environment.systemPackages = with pkgs; [
    sublime
    vlc
    imagemagick
  ];
  modules.desktop.enable = false;
  modules.plasma.enable = false;
  imalison.nixOverlay.enable = false;
  modules.wsl.enable = true;

  networking.hostName = "bencbox";

  wsl.defaultUser = "ben";
  system.stateVersion = "22.05";

  home-manager.users = forEachUser {
    home.stateVersion = "22.05";
  };

  users.users.ben = {
    extraGroups = [
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
    ] ++ ["wheel"];
  };
}
