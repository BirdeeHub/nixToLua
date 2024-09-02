# convert nix to lua

can convert nix to lua, except for uncalled nix functions.

```nix
inputs.nixToLua.url = "github:BirdeeHub/nixToLua";
```

```nixToLua.toLua```

use toLua to convert nix to lua

```nixToLua.mkLuaInline```

use mkLuaInline to allow insertion of unescaped lua code.

lua inline values cannot be interpolated into other nix strings.

this repo does not need to be imported as a flake, but is able to be.
