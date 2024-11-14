{ pkgs, nixToLua, luaEnv, ... }: {
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
    directmaybe = nixToLua.inline.types.function-safe.mk {
      args = [ "hello" ];
      body = /*lua*/ ''
        print(hello)
      '';
    };
    directmaybe42 = nixToLua.inline.types.function-unsafe.mk {
      args = [ "hi" "hello" ];
      body = /*lua*/ ''
        print(hi)
        print(hello)
      '';
    };

  };
}
