{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    vendor-kernel = {
      url = "github:yodalf/linux-smx6_5.8.18/main";
      #url = "github:yodalf/linux-smx6_5.8.18?ref=b7b42b90459da5f997dd314084b4941583e4e643";
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
        #./base.nix
        ./boot.nix
        ./configuration.nix
      ];
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
      };

    };
}
