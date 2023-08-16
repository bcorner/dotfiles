{ config, pkgs, options, inputs, ... }:
{
  imports = [
    ./environment.nix
    ./essential.nix
    ./nix.nix
    ./ssh.nix
    ./users.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.0.2u"
    "electron-12.2.3"
    "etcher"
  ];

  # Disabling these waits disables the stuck on boot up issue
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-user-sessions.enable = false;

  # Security
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
    package = pkgs.gnupg_2_4_0;
  };
  services.pcscd.enable = true;

  # Networking
  environment.etc."ipsec.secrets".text = ''
    include ipsec.d/ipsec.nm-l2tp.secrets
  '';

  networking.firewall.enable = false;
  networking.networkmanager = {
    enable = true;
    enableStrongSwan = true;
    plugins = [ pkgs.networkmanager-l2tp pkgs.networkmanager-openvpn ];
    extraConfig = ''
      [main]
      rc-manager=resolvconf
    '';
  };

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Printing
  # services.printing.enable = true;

  # Keyboard/Keymap
  console.keyMap = "us";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Update timezone automatically
  services.tzupdate.enable = true;

  # TODO: Add a comment explaining what this does.
  services.gnome.at-spi2-core.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.locate.enable = true;

  virtualisation.docker.enable = true;

  hardware.keyboard.zsa.enable = true;

  services.logind.extraConfig = "RuntimeDirectorySize=5G";

  services.dbus.packages = [ pkgs.gcr ];
}
