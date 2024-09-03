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
      (nixToLua.mkLuaInline ''[[I am a]] .. [[ lua ]] .. type("value")'') # --> "I am a lua string"
      '' multi line string
      tstasddas
      ddsdaa]====]
      ''
    ];
    "]=====]-!'.thing4" = "couch is for scratching";
    hmm = nixToLua.mkLuaInline /*lua*/ ''

      (function ()
        local a = 1
        local b = 2

        local c = 3
        return { a+b+c, "${pkgs.lolcat}" }
      end)()

    '';
  };
};
generated = pkgs.writeText "nixgen.lua" ''return ${nixToLua.toLua yourNixValue}'';
```

## Functions

```nixToLua.toLua```

use toLua to convert nix to lua

can convert any nix to lua, EXCEPT FOR UNCALLED NIX FUNCTIONS.

```nixToLua.mkLuaInline```

Use mkLuaInline to allow insertion of unescaped lua code.

If you could put it as a value in a lua table, you could put it here.

lua inline values **CANNOT** be interpolated into other nix strings.

other nix strings **CAN** be interpolated into lua inline values.

`nixToLua.prettyLua`

Will format the lua output with proper indentation.

If there is a multiline string, it will align it,
possibly altering spacing within the string itself.

If the spacing matters, use the following function:

`nixToLua.prettyNoModify`

Same as `nixToLua.prettyLua` but does not modify multiline inputs.

The output may look slightly less pretty, but it ensures your strings
will not be modified from how they would have been parsed by nix,
once read by lua.

## Examples

runnable examples are in a subdirectory called "examples"

```bash
nix run --show-trace github:BirdeeHub/nixToLua?dir=examples
```

running the above command will output the inspect print of the
lua table generated from the [examples/yourNixValue.nix](./examples/yourNixValue.nix) file.

```lua
{
  theBestCat = "says meow!!",
  theWorstCat = {
    ["]=====]-!'.thing4"] = "couch is for scratching",
    hmm = { 6, "/nix/store/h4fjrinvqsw97mnn31izx51lyn5dd1q6-lolcat-100.0.1" },
    ["thing'1"] = { "MEOW", "]]' ]=][=[HISSS]]\"[[" },
    thing2 = { {
        thing3 = { "give", "treat" }
      }, "I LOVE KEYBOARDS", "I am a lua string", "multi line string\n     tstasddas\n     ddsdaa]====]\n" }
  }
}
```
