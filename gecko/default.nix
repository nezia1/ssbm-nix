{
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "gecko";
  version = "3.4.0";
  vendorHash = null;

  src = fetchFromGitHub {
    owner = "JLaferri";
    repo = "gecko";
    rev = "v${finalAttrs.version}";
    sha256 = "1jqxcimpl58czvxi52jndrnzhhqmg0i4v5dp6amibg2wxwyy12w3";
  };

  # This avoid having to update the vendor hash on every update (see https://nixos.org/manual/nixpkgs/stable/#var-go-vendorHash)
  postPatch = ''
    go mod init gecko
  '';
})
