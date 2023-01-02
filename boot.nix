{ config, lib, pkgs, ... }:

{
  hardware.deviceTree.name = "kontron/imx6q-smx6-eval-valise.dtb";
  #hardware.deviceTree.name = "kontron/imx6q-smx6-lvds-pm070wl4.dtb";
  #hardware.deviceTree.name = "imx_v6_v7_defconfig";
  #hardware.devicetree.dtsFile = ./toto.dtb;

  ##isoImage.makeEfiBootable = true;
  ##isoImage.makeUsbBootable = true;

  boot = {
      consoleLogLevel = lib.mkDefault 7;
      
      kernelPackages = let
        linux_smx6_pkg = { fetchFromGitHub, buildLinux, ... } @ args:

          buildLinux (args // rec {
            version = "5.8.18";
            modDirVersion = version;

            src = fetchFromGitHub {
              owner = "yodalf";
              repo = "linux-smx6_5.8.18";
              rev = "main";
              sha256 = "sha256-JXUA8k6oUGCqjhlwa9N9T3Kb5YIJR5I1uVL0Hir5+Aw=";
            };
            kernelPatches = [];
            defconfig = "coresense_defconfig";
            #defconfig = "kontron_samx6i_defconfig";

            #structuredExtraConfig = with lib.kernel; {
            #  NLS_CODEPAGE_437 = lib.mkForce yes;
            #  NLS_ISO8859_1 = lib.mkForce yes;
            #  BLK_DEV_LOOP = lib.mkForce yes;
            #  ISO9660_FS = lib.mkForce yes;
            #};

            extraMeta = {
              branch = "5.8";
              description = "Linux kernel for Kontron's SMX6 board";
              platforms = [ "armv7l-linux" ];
              #hydraPlatforms = [ "armv7l-linux" ];
            };

            #extraConfig = ''
            #  INTEL_SGX y
            #'';

          } // (args.argsOverride or {}));
        linux_smx6 = pkgs.callPackage linux_smx6_pkg{};
      in 
        pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_smx6);




      kernelParams = [
        "console=ttymxc0,115200n8"
        "boot.shell_on_fail"
        "fbcon=map:0"
        #"root=/dev/disk/by-label/NIXOS"
        "findiso=/nixos.iso"
      ];

      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
        
        #grub.enable = true;
        #grub.efiSupport = true;
        ##grub.efiInstallAsRemovable = true;
        #grub.device = "nodev";
        #grub.extraConfig =  ''
        #  iso_path /nixos.iso
        #  textmode true
        #  '';  
        };
    

    initrd = {
        availableKernelModules = [
            "iso9660"
            "usbserial"
            "usb_storage"
            "squashfs"
            "nls_cp437"
            "overlay"
        ];
        
        kernelModules = [
            "iso9660"
            "usbserial"
            "usb_storage"
            "nls_cp437"
        ];

        supportedFilesystems = [
          "qnx6"
          "btrfs"
          "squashfs"
          "so9660"
          "overlay"
          "vfat"
        ];

        #network = {
        #    enable = true;
        #    ssh = {
        #      enable = true;
        #      hostKeys = [ ./dummy_rsa ];
        #      authorizedKeys = config.users.users.abb.openssh.authorizedKeys.keys;
        #    };

         #   # Set the shell profile to meet SSH connections with a decryption
         #   # prompt that writes to /tmp/continue if successful.
         #   postCommands = let
         #     disk = "/dev/disk/by-label/crypt";
         #   in ''
         #     # echo 'cryptsetup open ${disk} root --type luks && echo > /tmp/continue' >> /root/.profile
         #     # echo 'starting sshd...'
         #     echo 'sh && echo > /tmp/continue' >> /root/.profile
         #     echo 'YES ... starting ssh ...'
         #   '';
        #};

        # Block the boot process until /tmp/continue is written to
        #postDeviceCommands = ''
        #  echo 'I am waiting for /tmp/continue ...'
        #  mkfifo /tmp/continue
        #  cat /tmp/continue
        #'';
  };



    };


    sdImage = {
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
