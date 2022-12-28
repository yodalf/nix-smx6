{ config, lib, pkgs, ... }:

{
  #hardware.deviceTree.name = "kontron/imx6q-smx6-lvds-pm070wl4.dtb";
  hardware.deviceTree.name = "kontron/imx6q-smx6-eval-valise.dtb";
  #hardware.devicetree.dtsFile = ./toto.dtb;

  boot = {
      consoleLogLevel = lib.mkDefault 7;
      kernelPackages = pkgs.linuxPackages_smx6;
      
      kernelParams = [
        "console=tty0"
        "console=ttymxc0,115200n8"
        "console=ttyS0,115200n8"
        #"earlycon=sbi"
      ];

      initrd.kernelModules = [
        #"dw-axi-dmac-platform"
        #"dw_mmc-pltfm"
        #"spi-dw-mmio"
      ];

      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    };


  sdImage = {
      imageName = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-coresense.img";

      # We have to use custom boot firmware since we do not support
      # StarFive's Fedora MMC partition layout. Thus, we include this in
      # the image's firmware partition so the user can flash the custom firmware.
      populateFirmwareCommands = ''
      '';

      populateRootCommands = ''
        mkdir -p ./files/boot
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
      '';
    };




}
