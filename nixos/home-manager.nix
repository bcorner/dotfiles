inputs: { pkgs, config, ... }: {
  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
    importedVariables = [ "GDK_PIXBUF_ICON_LOADER" ];
  };

  home.keyboard = null;
  home.emptyActivationPath = false;
  programs.home-manager.enable = true;

  programs.ssh = {
    forwardAgent = true;
  };

  services.xscreensaver = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 8 * 60 * 60;
    maxCacheTtl = 8 * 60 * 60;
    enableSshSupport = true;
    pinentryFlavor = "qt";
  };

  services.blueman-applet = {
    enable = false;
  };

  services.taffybar = {
    enable = true;
    package = inputs.imalison-taffybar.defaultPackage."${pkgs.system}";
  };

  services.notify-osd = {
    enable = true;
    package = pkgs.notify-osd-customizable;
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  services.network-manager-applet.enable = true;

  services.udiskie = {
    enable = true;
    tray = "always";
  };

  services.status-notifier-watcher.enable = true;

  services.random-background = {
    enable = true;
    display = "fill";
    interval = "1h";
    imageDirectory = "%h/Pictures/wallpaper/use";
  };

  services.xsettingsd.enable = true;

  services.volnoti.enable = true;

  services.parcellite = {
    enable = true;
    package = pkgs.clipit;
  };

  services.git-sync = {
    enable = true;
    repositories = {
      config = {
        path = config.home.homeDirectory + "/config";
        uri = "git@github.com:IvanMalison/config.git";
      };
      org = {
        path = config.home.homeDirectory + "/org";
        uri = "git@github.com:IvanMalison/org.git";
      };
      password-store = {
        path = config.home.homeDirectory + "/.password-store";
        uri = "git@github.com:IvanMalison/.password-store.git";
      };
    };
  };

  systemd.user.services.setxkbmap = {
    Unit = {
      Description = "Set up keyboard in X";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/usr/bin/env load_xkb_map";
    };
  };

  systemd.user.services.notifications-tray-icon = {
    Unit = {
      Description = "Notifications tray icon";
      After = [ "graphical-session-pre.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.haskellPackages.notifications-tray-icon}/bin/notifications-tray-icon  --github-token-pass dfinity-github-api-token";
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.shutter = {
    Unit = {
      Description = "Shutter";
      After = [ "graphical-session-pre.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.shutter}/bin/shutter --min_at_startup";
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.picom = {
    Unit = {
      Description = "Picom X11 compositor";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.picom}/bin/picom --experimental-backends";
      Restart = "always";
      RestartSec = 3;
    };
  };

  home.stateVersion = "21.05";
}
