{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
  in {
    packages = forAllSys (system: let
      pkgs = import nixpkgs { inherit system; };
      luaEnv = pkgs.luajit.withPackages (p: with p; [ inspect ]);
      examples = {
        default = ./yourNixValue.nix;
      };
      nixToLua = import ../.;
      buildExample = name: path: pkgs.writeShellScriptBin name (let
        import_table = (import "${path}" { inherit pkgs luaEnv nixToLua; });
        luaFile = pkgs.writeText "${name}.lua" /*lua*/''
          local inspect = require 'inspect'
          print(inspect(${nixToLua.toLua import_table}))
        '';
      in /*bash*/''
        ${luaEnv}/bin/lua ${luaFile}
      '');
    in builtins.mapAttrs buildExample examples);
  };
}
