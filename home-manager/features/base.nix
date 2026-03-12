{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    eza
    bat
    jq
    htop
    tree
    curl
    wget
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
