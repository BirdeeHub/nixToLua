{ pkgs, nixToLua, luaEnv, ... }: let
  # you cant put uncalled functions into the table.
  # when lua reads them, nix is finished.
  # the package has already been installed.
  # so it cant run nix functions in lua.
  functions = pkgs: {
    test = pkgs.writeShellScriptBin "ImaScript" ''
      echo "Hello World!"
    '';
    test2 = nixToLua.mkLuaInline /*lua*/''
      require('inspect')({ "this", "is", "a", "test" })
    '';
  };
  # you can call them in the table though!
  # (as long as they dont return a nix function)
in

rec {
  somevalue = {
    eventhis = [ "some" "values" ];
  };
  again = somevalue;
  "recursion? no problem" = again;
  "yes this also works" = functions pkgs;
  nix_doesnt_allow_this_though = "yes this also works";
  yes_this_also_works = functions pkgs;
  "this is fine though" = yes_this_also_works;
  hmm = nixToLua.mkLuaInline /*lua*/ ''
    {
      PKG_LOADED = package.loaded,
      PKG_PATH = package.path,
      PKG_CPATH = package.cpath,
    }
  '';
}
