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
outputs = { nixToLuaNonFlake, ... }: {
  nixToLua = import nixToLuaNonFlake;
};
# or any other way you can fetch it and call import on it
```

## Useage:

```nix
{ pkgs, nixToLua, ... }: rec {
  theBestCat = "says meow!!";
  # yes even tortured inputs work.
  theWorstCat = {
    thing'1 = [ "MEOW" '']]' ]=][=[HISSS]]"[['' ];
    thing2 = [
      {
        thing3 = [ "give" "treat" ];
      }
      "I LOVE KEYBOARDS"
      (nixToLua.inline.types.inline-unsafe.mk { body = ''[[I am a]] .. [[ lua ]] .. type("value")''; }) # --> "I am a lua string"
      '' multi line string
      tstasddas
      ddsdaa]====]
      ''
      (nixToLua.inline.types.inline-safe.mk ''[[I am at ]] .. os.getenv("HOME") or "home?" .. " here!!"'')
    ];
    "]=====]-!'.thing4" = "couch is for scratching";
    hmm = nixToLua.inline.types.inline-safe.mk { body = /*lua*/ ''

        (function ()
          local a = 1
          local b = 2

          local c = 3
          return { a+b+c, "${pkgs.lolcat}" }
        end)()

      '';
    };
    exampleSafeFunc = nixToLua.inline.types.function-safe.mk {
      args = [ "hello" ];
      body = /*lua*/ ''
        print(hello)
        return hello
      '';
    };
    exampleUnsafeFunc = nixToLua.inline.types.function-unsafe.mk {
      args = [ "hi" "hello" ];
      body = /*lua*/ ''
        print(hi)
        print(hello)
        return hi .. hello
      '';
    };
  };
  funcResults = {
    test1 = nixToLua.inline.types.inline-safe.mk ''${nixToLua.resolve theWorstCat.exampleSafeFunc}("Hello World!")'';
    test2 = nixToLua.inline.types.inline-safe.mk ''${nixToLua.resolve theWorstCat.exampleUnsafeFunc}("Hello World!", "and again!")'';
  };
}
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
Hello World!
Hello World!
and again!
{
  funcResults = {
    test1 = "Hello World!",
    test2 = "Hello World!and again!"
  },
  theBestCat = "says meow!!",
  theWorstCat = {
    ["]=====]-!'.thing4"] = "couch is for scratching",
    exampleSafeFunc = <function 1>,
    exampleUnsafeFunc = <function 2>,
    hmm = { 6, "/nix/store/h4fjrinvqsw97mnn31izx51lyn5dd1q6-lolcat-100.0.1" },
    ["thing'1"] = { "MEOW", "]]' ]=][=[HISSS]]\"[[" },
    thing2 = { {
        thing3 = { "give", "treat" }
      }, "I LOVE KEYBOARDS", "I am a lua string", "multi line string\n     tstasddas\n     ddsdaa]====]\n", "I am at /home/birdee" }
  }
}
```

- extra examples:

```bash
nix run --show-trace github:BirdeeHub/nixToLua?dir=examples#anotherNixValue
```

- Extending with new inline types:

You will want access to the functions from nixToLua to define your type.
So, first get a preliminary copy, and make it overridable.

```nix
n2l = pkgs.lib.makeOverridable (import "${nixToLua}/lib.nix") {}
```

Now you can `n2l.override { /* your typedefs here */ }` and you will get back a library outfitted to handle the new types.

See the typedefs in [./lib.nix](./lib.nix) for examples.
