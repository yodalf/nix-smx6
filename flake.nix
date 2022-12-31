{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    #nixpkgs.url = "nixpkgs/nixos-22.11";
    vendor-kernel = {
      url = "github:yodalf/linux-smx6_5.8.18/main";
      #url = "github:yodalf/linux-smx6_5.8.18/?ref=1d56ce00236f73277ef610930257f751c5159b2f";
      #url = "git+https://gitlab.kontron.com/imx/linux-imx.git?ref=samx6i_5.8.18";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, vendor-kernel }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
      modules = [
        { nixpkgs.overlays = [ self.overlay ]; }
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
        #"${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        #./my-sd-image.nix
        ./boot.nix
        ./configuration.nix
        #./image.nix
      ];
      #squashfsKit = pkgs.squashfsTools.overrideDerivation (oldAttrs: {
      #  src = pkgs.fetchFromGitHub {
      #    owner = "squashfskit";
      #    repo = "squashfskit";
      #    sha256 = "1qampwl0ywiy9g2abv4jxnq33kddzdsq742ng5apkmn3gn12njqd";
      #    rev = "3f97efa7d88b2b3deb6d37ac7a5ddfc517e9ce98";
      #    };
      #  }); 
    in
    {
      # Obtain a kernel from the vendor-kernel source
      overlay = final: prev: {
        # Fix missing AHCI driver (and any other) in intrd
        makeModulesClosure = x:
          prev.makeModulesClosure (x // { allowMissing = true; });
          
        linuxPackages_smx6 = final.linuxPackagesFor ((final.callPackage ./kernel.nix { inherit vendor-kernel; }).override { patches = []; });
      };

      # Save the kernel packages in our pkgs
      legacyPackages.${system} =
        {
          inherit (pkgs.pkgsCross.armv7l.linux) linuxPackages_smx6;
        };

      nixosConfigurations = {
        smx6 = nixpkgs.lib.nixosSystem {
          system = "${system}";
          modules = modules ++ [
            {
              nixpkgs.crossSystem = {
                system = "armv7l-linux";
              };
            }
          ];
        };
      };

      
      images = {
        smx6 = self.nixosConfigurations.smx6.config.system.build.sdImage;
        #iso = self.nixosConfigurations.smx6.config.system.build.isoImage;
      };
######
      X =
        let 
          smx6 = self.nixosConfigurations.smx6;
          
        in  
        pkgs.stdenv.mkDerivation {
          name = "smx6.squashfs";
          #src = ./hello.tar.gz;

          nativeBuildInputs = [ pkgs.squashfsTools ];
          
          
          buildCommand =
            ''
              #closureInfo=${pkgs.closureInfo { rootPaths = [  ]; }}
              closureInfo=${pkgs.closureInfo { rootPaths = pkgs.hello; }}
              # Uncomment to print dependencies in the build log.
              # This is the easiest way I've found to do this.
              #echo "BEGIN DEPS"
              #cat $closureInfo/store-paths
              #echo "END DEPS"
              # TODO: Put symlinks binaries in /usr/bin.
              # Generate the squashfs image. Pass the -no-fragments option to make
              # the build reproducible; apparently splitting fragments is a
              # nondeterministic multithreaded process. Also set processors to 1 for
              # the same reason.
              mksquashfs $(cat $closureInfo/store-paths) $out \
                -no-fragments      \
                -processors 1      \
                -keep-as-directory \
                -all-root          \
                -b 1048576         \
                -comp xz           \
                -Xdict-size 100%   \
            '';
          };
######


  };
}
