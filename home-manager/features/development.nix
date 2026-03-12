{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixfmt
    statix
    deadnix
    gh
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
