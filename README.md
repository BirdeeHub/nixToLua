# nix to lua

this repo does not need to be imported as a flake, but is able to be.

```nix
inputs.nixToLua.url = "github:BirdeeHub/nixToLua";
outputs = { nixToLua, ... }: {
};
```

- or

```nix
inputs.nixToLuaNonFlake = {
  url = "github:BirdeeHub/nixToLua";
  flake = false;
};
outputs.nixToLua = { nixToLuaNonFlake, ... }: {
  nixToLua = import nixToLuaNonFlake;
};
# or any other way you can fetch it and call import on it
```

## Useage:

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
      (mkLuaInline ''[[I am a]] .. [[ lua ]] .. type("value")'') # --> "I am a lua string"
      '' multi line string
      tstasddas
      ddsdaa]====]
      ''
    ];
    "]=====]-!'.thing4" = "couch is for scratching";
  };
};
generated = pkgs.writeText "nixgen.lua" ''return ${nixToLua.toLua yourNixValue}'';
```

```nixToLua.toLua```

use toLua to convert nix to lua

can convert nix to lua, EXCEPT FOR UNCALLED NIX FUNCTIONS.

```nixToLua.mkLuaInline```

use mkLuaInline to allow insertion of unescaped lua code.

lua inline values **CANNOT** be interpolated into other nix strings.

other nix strings **CAN** be interpolated into lua inline values.

```nix
nix repl --show-trace
Welcome to Nix 2.18.5. Type :? for help.

nix-repl> :lf .
warning: Git tree '/home/birdee/Projects/nixToLua' is dirty
Added 13 variables.

nix-repl> toLua (import ./testVals.nix).yourNixValue
"{ [ [[theBestCat]] ] = [[says meow!!]], [ [[theWorstCat]] ] = { [ [======[]=====]-!'.thing4]======] ] = [[couch is for scratching]], [ [[hmm]] ] = (function ();  local a = 1;  local b = 2;  local c = 3;  return a+b+c;end)();, [ [[thing'1]] ] = { [[MEOW]], [==[]]' ]=][=[HISSS]]\"[[]==] }, [ [[thing2]] ] = { { [ [[thing3]] ] = { [[give]], [[treat]] } }, [[I LOVE KEYBOARDS]], [[I am a]] .. [[ lua ]] .. type(\"value\"), [=====[multi line string\n       tstasddas\n       ddsdaa]====]\n]=====] } } }"
```
