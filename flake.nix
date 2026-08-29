# CV / portfolio site flake.
#
# Builds the static site with Zola (nixpkgs pin 0.22.1). The nixpkgs rev is
# hard-pinned to the same rev as nixos-config's flake.lock input
# (9ae611a455b90cf061d8f332b977e387bda8e1ca, Tier 0 §3.2) so the site builds
# with the same zola 0.22.1 everywhere. Bump deliberately.
{
  description = "Personal CV / portfolio site — content-driven, Zola static site";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/9ae611a455b90cf061d8f332b977e387bda8e1ca";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # `nix build .#site` → the rendered public/ directory.
          site = pkgs.stdenv.mkDerivation {
            pname = "cv-site";
            version = "0.1.0";
            src = self;
            nativeBuildInputs = [ pkgs.zola ];
            buildPhase = ''
              zola build --output-dir $out
            '';
          };
          default = self.packages.${system}.site;
        });
    };
}