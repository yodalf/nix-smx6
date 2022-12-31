{ lib
, buildLinux
, vendor-kernel
, ... } @ args:

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
  version = "${modDirVersion}-smx6";

  src = vendor-kernel;

  kernelPatches = [];

  defconfig = "coresense_defconfig";
  #defconfig = "kontron_samx6i_defconfig";

  #structuredExtraConfig = with lib.kernel; {
  #};

  #extraMeta = {
  #  description = "Linux kernel for Kontron's SMX6 board";
  #  platforms = [ "armv7l-linux" ];
  #  hydraPlatforms = [ "armv7l-linux" ];
  #};
} // (args.argsOverride or { }))
