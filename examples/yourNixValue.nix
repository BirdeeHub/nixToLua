{ pkgs, nixToLua, luaEnv, ... }: rec {
  theBestCat = "says meow!!";
  # yes even tortured inputs work.
  theWorstCat = {
    thing'1 = [ "MEOW]" '']]' ]=][=[HISSS]]"[['' ];
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
    hasmeta = nixToLua.inline.types.with-meta.mk (let
      tablevar = "tbl_in";
    in {
      table = {
        this = "is a test var";
        inatesttable = "that will be translated to a lua table with a metatable";
      };
      newtable = null;
      inherit tablevar;
      meta = {
        __call = nixToLua.inline.types.function-unsafe.mk {
          args = [ "_" "attrpath" "..." ];
          body = /*lua*/ ''
            local strtable = {}
            if type(attrpath) == "table" then
                strtable = attrpath
            elseif type(attrpath) == "string" then
                for key in attrpath:gmatch("([^%.]+)") do
                    table.insert(strtable, key)
                end
            else
                print('function requires a { "list", "of", "strings" } or a "dot.separated.string"')
                return
            end
            if #strtable == 0 then return nil end
            local tbl = ${tablevar};
            for _, key in ipairs(strtable) do
              if type(tbl) ~= "table" then return nil end
              tbl = tbl[key]
            end
            return tbl
          '';
        };
      };
    });
  };
  funcResults = {
    test1 = nixToLua.inline.types.inline-safe.mk ''${nixToLua.resolve theWorstCat.exampleSafeFunc}("Hello World!")'';
    test2 = nixToLua.inline.types.inline-safe.mk ''${nixToLua.resolve theWorstCat.exampleUnsafeFunc}("Hello World!", "and again!")'';
    checkaval = nixToLua.inline.types.function-safe.check theWorstCat.exampleSafeFunc;
    checkaval2 = nixToLua.inline.types.function-safe.check theWorstCat.exampleUnsafeFunc;
  };
}
