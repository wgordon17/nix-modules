_: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    casks = [ ];
    brews = [ ];
  };

  environment.systemPath = [ "/opt/homebrew/bin" ];
}
