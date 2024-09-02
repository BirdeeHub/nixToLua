{ pkgs, nixToLua, luaEnv, ... }: {
  hmm = nixToLua.mkLuaInline /*lua*/ ''
    {
      PKG_LOADED = package.loaded,
      PKG_PATH = package.path,
      PKG_CPATH = package.cpath,
    }
  '';
}
