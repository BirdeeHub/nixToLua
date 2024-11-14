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

## Translators

`nixToLua.toLua`

Will format the lua output with proper indentation.

Will avoid modifying indentation on multiline inputs.

The output may look slightly less pretty, but it ensures your strings
will not be modified from how they would have been parsed by nix,
once read by lua.

`nixToLua.prettyLua`

Will format the lua output with proper indentation.

Same as `nixToLua.toLua` except will realign multiline inputs.

If there is a multiline string, it will align it,
possibly altering spacing within the string itself.

If the spacing within the input matters, use the above function.

```nixToLua.uglyLua```

use toLua to convert nix to lua, all 1 line

can convert any nix to lua, EXCEPT FOR UNCALLED NIX FUNCTIONS.

## Helpers

TODO: fill this out with the new scheme

For now, go look at the examples.

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

- extra examples:

```bash
nix run --show-trace github:BirdeeHub/nixToLua?dir=examples#anotherNixValue
```
