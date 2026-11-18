{...}: [
  {
    location = "bottom";
    height = 46;
    alignment = "center";
    lengthMode = "fill";
    opacity = "adaptive";
    floating = false;
    hiding = "none";
    widgets = [
      "org.kde.plasma.panelspacer"
      {
        kickoff = {
          icon = "nix-snowflake-white";
        };
      }
      {
        iconTasks = {
          launchers = [
            "applications:systemsettings.desktop"
            "preferred://filemanager"
            "preferred://browser"
            "applications:steam.desktop"
            "applications:input-remapper-gtk.desktop"
          ];
        };
      }
      "org.kde.plasma.marginsseparator"
      "org.kde.plasma.panelspacer"
      "org.kde.plasma.systemtray"
      "org.kde.plasma.digitalclock"
      "org.kde.plasma.showdesktop"
    ];
  }
]
