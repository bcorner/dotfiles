{ config, lib, pkgs, ... }:

{
  imports = [
    ../configuration.nix
  ];

  modules.base.enable = true;
  modules.desktop.enable = true;
  modules.xmonad.enable = true;
  modules.extra.enable = false;
  modules.code.enable = true;
  modules.games.enable = false;
  modules.syncthing.enable = true;
  modules.fonts.enable = true;
  modules.nixified-ai.enable = false;

  hardware.enableRedistributableFirmware = true;

  # disable card with bbswitch by default since we turn it on only on demand!
  hardware.nvidiaOptimus.disable = true;

  # install nvidia drivers in addition to intel one
  hardware.opengl.extraPackages = [ pkgs.linuxPackages.nvidia_x11.out ];
  hardware.opengl.extraPackages32 = [ pkgs.linuxPackages.nvidia_x11.lib32 ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.libinput.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/58218a04-3ba1-4295-86bb-ada59f75e3b6";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/8142784e-45c6-4a2b-91f1-09df741ac00f";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/36E1-BE93";
    fsType = "vfat";
  };

  systemd.services.resume-fix = {
    description = "Fixes acpi immediate resume after suspend";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" "post-resume.target" ];
    script = ''
      if ${pkgs.gnugrep}/bin/grep -q '\bXHC\b.*\benabled\b' /proc/acpi/wakeup; then
      echo XHC > /proc/acpi/wakeup
      fi
    '';
    serviceConfig.Type = "oneshot";
  };

  swapDevices = [
    {
      device = "/swapfile";
      priority = 0;
      size = 4096;
    }
  ];

  networking.hostName = "ivanm-dfinity-razer";

  nix.settings.maxJobs = lib.mkDefault 12;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  system.stateVersion = "18.03";
}
