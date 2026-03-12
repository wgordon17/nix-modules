{ pkgs, ... }:
{
  imports = [ ./homebrew.nix ];

  nix.gc = {
    automatic = true;
    interval.Day = 7;
    options = "--delete-older-than 7d";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;

  environment.variables = {
    EDITOR = "vim";
    LANG = "en_US.UTF-8";
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Always";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowStatusBar = true;
        ShowPathbar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        QuitMenuItem = true;
      };

      dock = {
        autohide = true;
        tilesize = 42;
        show-recents = false;
        minimize-to-application = true;
      };

      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      trackpad.Clicking = true;
    };

    startup.chime = false;

    stateVersion = 4;
  };
}
