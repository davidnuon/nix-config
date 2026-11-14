{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.mixins.base.enable {
    # Install Japanese IME MOZC
    i18n.inputMethod.type = "ibus";
    i18n.inputMethod.enable = true;
    i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc];
  };
}
