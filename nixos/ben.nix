{
  pkgs,
  inputs,
  config,
  makeEnable,
  ...
}:
makeEnable config "myModules.ben" true {
  home-manager.users.ben = {
    imports = [
      ./emacs.nix
      ./dotfiles-links.nix
    ];

    programs.zsh = {
      enable = true;
      # NixOS initializes completion through oh-my-zsh after setting
      # ZSH_DISABLE_COMPFIX for the group-writable shared checkout. A second
      # Home Manager compinit runs too early and blocks on an insecure-directory
      # prompt for /srv/dotfiles, making shell startup appear to hang.
      enableCompletion = false;
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
