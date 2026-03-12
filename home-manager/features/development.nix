{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    statix
    deadnix
    gh
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
