{ config, pkgs, ... }:
{
  services.expressvpn.enable = true;
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    android-studio
    ffmpeg
    asciidoctor
    roomeqwizard
    razergenie
    expressvpn
    signal-desktop
    gource
    gimp
    texlive.combined.scheme-full
    tor
  ];
}
