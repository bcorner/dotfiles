{
  config,
  inputs,
  lib,
  makeEnable,
  pkgs,
  ...
}: let
  paseoUser =
    if config.myModules.wsl.enable
    then config.wsl.defaultUser
    else "imalison";
  paseoGroup = config.users.users.${paseoUser}.group;
  paseoPackage = import ./paseo-node-pty-workaround.nix {
    paseo = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  remoteAccessEnabled = config.services.tailscale.enable;
  bindsTailscaleAddress =
    remoteAccessEnabled
    && config.services.paseo.listenAddress != "0.0.0.0";
in
  makeEnable config "myModules.paseo" false {
    imports = [inputs.paseo.nixosModules.default];

    services.paseo = {
      enable = true;
      package = paseoPackage;
      user = paseoUser;
      group = paseoGroup;
      listenAddress = lib.mkDefault "0.0.0.0";
      port = 6767;

      # Accept the machine's MagicDNS short name in addition to IP addresses,
      # which Paseo permits automatically.
      hostnames = [config.networking.hostName];
    };

    # Paseo binds all addresses so it can accept the Tailscale interface, but
    # only expose its port through that interface. In particular, do not use
    # services.paseo.openFirewall, which would also expose it on LAN interfaces.
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
      config.services.paseo.port
    ];

    age.secrets.paseo-password-environment = lib.mkIf remoteAccessEnabled {
      file = ./secrets/paseo-password-environment.age;
      owner = config.services.paseo.user;
      group = config.services.paseo.group;
      mode = "0400";
    };
    age.identityPaths = lib.mkIf remoteAccessEnabled (
      lib.mkAfter ["/home/${paseoUser}/.ssh/id_ed25519"]
    );

    systemd.services.paseo = lib.mkMerge [
      {
        # Rebuilds driven from a terminal or agent that lives inside
        # paseo.service's own cgroup die when switch-to-configuration stops the
        # unit, so the switch's start phase never runs and paseo stays down.
        # Upholds= makes systemd itself start the unit again whenever it is
        # found inactive while multi-user.target is up.
        upheldBy = ["multi-user.target"];
        environment = {
          HOME = "/home/${paseoUser}";
          LOGNAME = paseoUser;
          USER = paseoUser;
        };
        serviceConfig.WorkingDirectory = "/home/${paseoUser}";
        preStart = let
          ensurePaseoMcpInjection = import ../nix-shared/ensure-paseo-mcp-injection.nix {inherit pkgs;};
        in
          lib.mkAfter ''
            ${ensurePaseoMcpInjection} ${lib.escapeShellArg "${config.services.paseo.dataDir}/config.json"}
          '';
      }
      (lib.mkIf remoteAccessEnabled {
        after = ["agenix.service" "tailscaled.service"];
        wants = ["tailscaled.service"];
        serviceConfig.EnvironmentFile = config.age.secrets.paseo-password-environment.path;
      })
      (lib.mkIf bindsTailscaleAddress {
        preStart = lib.mkBefore ''
          ${pkgs.tailscale}/bin/tailscale wait
          ${pkgs.tailscale}/bin/tailscale ip --assert=${lib.escapeShellArg config.services.paseo.listenAddress}
        '';
      })
    ];

    home-manager.users.${paseoUser}.imports = [
      ../nix-shared/home-manager/paseo-settings-seed.nix
    ];
  }
