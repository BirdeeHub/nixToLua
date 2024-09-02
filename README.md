# convert nix to lua

```nix
inputs.nixToLua.url = "github:BirdeeHub/nixToLua";
```

```nix
yourNixValue = {
  theBestCat = "says meow!!";
  # yes even tortured inputs work.
  theWorstCat = {
    thing'1 = [ "MEOW" '']]' ]=][=[HISSS]]"[['' ];
    thing2 = [
      {
        thing3 = [ "give" "treat" ];
      }
      "I LOVE KEYBOARDS"
      (utils.mkLuaInline ''[[I am a]] .. [[ lua ]] .. type("value")'')
    ];
    thing4 = "couch is for scratching";
  };
};
generated = pkgs.writeText "nixgen.lua" ''return ${nixToLua.toLua yourNixValue}'';
```

```nixToLua.toLua```

use toLua to convert nix to lua

can convert nix to lua, EXCEPT FOR UNCALLED NIX FUNCTIONS.

```nixToLua.mkLuaInline```

use mkLuaInline to allow insertion of unescaped lua code.

lua inline values cannot be interpolated into other nix strings.

this repo does not need to be imported as a flake, but is able to be.
