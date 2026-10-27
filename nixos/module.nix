{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.abcde;

  # Render an attrset of settings into abcde.conf "KEY=value" lines. abcde
  # sources this file as shell, so values are shell-quoted.
  renderConf = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: value:
      let
        v =
          if lib.isBool value then
            (if value then "y" else "n")
          else if lib.isInt value then
            toString value
          else
            lib.escapeShellArg value;
      in
      "${name}=${v}"
    ) cfg.settings
  );

  # settings first, then any raw extraConfig (e.g. shell function overrides).
  etcText =
    lib.concatStringsSep "\n" (lib.filter (s: s != "") [
      renderConf
      cfg.extraConfig
    ])
    + "\n";
in
{
  options.programs.abcde = {
    enable = lib.mkEnableOption "abcde, a command-line audio CD ripper";

    package = lib.mkPackageOption pkgs "abcde" { };

    settings = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);
      default = { };
      example = lib.literalExpression ''
        {
          OUTPUTTYPE = "flac";
          CDROMREADERSYNTAX = "cdparanoia";
          OUTPUTDIR = "/srv/music";
        }
      '';
      description = "Variables written to {file}`/etc/abcde.conf`. Booleans render as abcde's `y`/`n`.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        munge_simplify_punctuation () {
            sed -e "s/\xe2\x80\x99/'/g" -e 's/\r//g'
        }
      '';
      description = "Extra lines appended verbatim to {file}`/etc/abcde.conf`, written without quoting.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # abcde reads /etc/abcde.conf after the package's baked defaults and before
    # ~/.abcde.conf, so this is the right layer for system-wide overrides.
    environment.etc."abcde.conf" = lib.mkIf (cfg.settings != { } || cfg.extraConfig != "") {
      text = etcText;
    };
  };
}
