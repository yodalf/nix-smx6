{ config, lib, pkgs, ... }:

{
  #hardware.deviceTree.name = "kontron/imx6q-smx6-lvds-pm070wl4.dtb";
  #hardware.deviceTree.name = "imx_v6_v7_defconfig";
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

      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    

    initrd = {
        kernelModules = [
            #"squashfs"
            #"iso9660"
            #"uas"
            #"overlay"
            #"usbserial"
            #"usb_storage"
        ];

        supportedFilesystems = [
            #"btrfs"
            #"squashfs"
            #"iso9660"
            #"overlay"
        ];

        network = {
            enable = true;
            ssh = {
              enable = true;
              hostKeys = [ ./dummy_rsa ];
              authorizedKeys = config.users.users.abb.openssh.authorizedKeys.keys;
            };

            # Set the shell profile to meet SSH connections with a decryption
            # prompt that writes to /tmp/continue if successful.
            postCommands = let
              disk = "/dev/disk/by-label/crypt";
            in ''
              # echo 'cryptsetup open ${disk} root --type luks && echo > /tmp/continue' >> /root/.profile
              # echo 'starting sshd...'
              echo 'sh && echo > /tmp/continue' >> /root/.profile
              echo 'YES ... starting ssh ...'
            '';
        };

        # Block the boot process until /tmp/continue is written to
        postDeviceCommands = ''
          echo 'I am waiting for /tmp/continue ...'
          mkfifo /tmp/continue
          cat /tmp/continue
        '';
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
