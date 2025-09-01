{
  pkgs,
  slippi-desktop,
}: let
  inherit (pkgs) lib;
  inherit (lib.customisation) makeScope;
  inherit (lib.attrsets) isDerivation isAttrs concatMapAttrs;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.filesystem) packagesFromDirectoryRecursive;

  # This constructs a by-name overlay similar to the one found in Nixpkgs.
  # The goal is to automatically discover and packages found in pkgs/by-name
  # as long as they have a 'package.nix' in the package directory. We also
  # pass 'inputs' and 'pins' to all packages in the 'callPackage' scope, therefore
  # they are always available in the relevant 'package.nix' files.
  # ---
  # The logic is borrowed from drupol/pkgs-by-name-for-flake-parts, available
  # under the MIT license.
  flattenPkgs = separator: path: value:
    if isDerivation value
    then {
      ${concatStringsSep separator path} = value;
    }
    else if isAttrs value
    then concatMapAttrs (name: flattenPkgs separator (path ++ [name])) value
    else
      # Ignore the functions which makeScope returns
      {};

  directoryScope = makeScope pkgs.newScope (self:
    {inherit slippi-desktop;}
    // packagesFromDirectoryRecursive {
      directory = ./pkgs/by-name;
      inherit (self) callPackage newScope;
    });
in
  (flattenPkgs "/" [] directoryScope)
  // (lib.fixedPoints.fix (self: {
    slippi-playback = directoryScope.callPackage ./slippi/package.nix {
      playbackSlippi = true;
    };
    slippi-netplay = directoryScope.callPackage ./slippi/package.nix {
      playbackSlippi = false;
    };
    slippi-netplay-chat-edition = self.slippi-netplay.overrideAttrs (oldAttrs: {
      pname = "slippi-ishiiruka-chat";
      version = "release/2.3.0";
      name = oldAttrs.pname;
      src = pkgs.fetchFromGitHub {
        owner = "project-slippi";
        repo = "Ishiiruka";
        rev = oldAttrs.version;
        sha256 = "1rd449s00dqmngp3mrapg91k4hhg2kyc0kizc37vb4l2zswpkqah";
      };
    });
  }))
