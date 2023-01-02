{ lib
, buildLinux
, vendor-kernel
, kmod, ... } @ args:

let
  kernelVersion = rec {
    # Fully constructed string, example: "5.10.0-rc5".
    string = "${version + "." + patchlevel + "." + sublevel + (lib.optionalString (extraversion != "") extraversion)}";
    file = "${vendor-kernel}/Makefile";
    version = toString (builtins.match ".+VERSION = ([0-9]+).+" (builtins.readFile file));
    patchlevel = toString (builtins.match ".+PATCHLEVEL = ([0-9]+).+" (builtins.readFile file));
    sublevel = toString (builtins.match ".+SUBLEVEL = ([0-9]+).+" (builtins.readFile file));
    # rc, next, etc.
    extraversion = toString (builtins.match ".+EXTRAVERSION = ([a-z0-9-]+).+" (builtins.readFile file));
  };
  modDirVersion = "${kernelVersion.string}";
in buildLinux (args // {
  inherit modDirVersion;
  version = "${modDirVersion}-kontron";

  src = vendor-kernel;

  kernelPatches = [];

  defconfig = "coresense_defconfig";
  #defconfig = "kontron_samx6i_defconfig";

  structuredExtraConfig = with lib.kernel; {
    NLS_CODEPAGE_437 = lib.mkForce yes;
    NLS_ISO8859_1 = lib.mkForce yes;
    BLK_DEV_LOOP = lib.mkForce yes;
    ISO9660_FS = lib.mkForce yes;
  };

  extraMeta = {
    description = "Linux kernel for Kontron's SMX6 board";
    platforms = [ "armv7l-linux" ];
    #hydraPlatforms = [ "armv7l-linux" ];
  };
} // (args.argsOverride or { }))
