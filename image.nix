{ pkgs, ...}:
with pkgs;
let 
  squashfsKit = squashfsTools.overrideDerivation (oldAttrs: {
    src = fetchFromGitHub {
      owner = "squashfskit";
      repo = "squashfskit";
      sha256 = "1qampwl0ywiy9g2abv4jxnq33kddzdsq742ng5apkmn3gn12njqd";
      rev = "3f97efa7d88b2b3deb6d37ac7a5ddfc517e9ce98";
    };
  });
in
 stdenv.mkDerivation {
    name = "miniserver";

    #nativeBuildInputs = [ squashfsKit ];
    #buildInputs = [  ];

    buildCommand =
      ''
        closureInfo=${closureInfo { rootPaths = [  ]; }}
        # Uncomment to print dependencies in the build log.
        # This is the easiest way I've found to do this.
        # echo "BEGIN DEPS"
        # cat $closureInfo/store-paths
        # echo "END DEPS"
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
  } 
