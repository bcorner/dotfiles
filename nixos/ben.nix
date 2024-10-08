{ pkgs, inputs, config, makeEnable, ... }:
makeEnable config "myModules.ben" true {
  home-manager.backupFileExtension = "backup"; # Add this line
  home-manager.users.ben = {
    programs.zsh = {
      enable = true;
      shellAliases = {
        l = "ls -CF";
        la = "ls -A";
        ll = "ls -lh";
        lla = "ls -alh";
        ls = "ls --color=auto";
        gts = "git status";
        gtl = "git log";
      };
    };
  };
}
