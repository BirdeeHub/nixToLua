with (import ./.); {
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
      hmm = mkLuaInline /*lua*/ ''

        (function ()
          local a = 1
          local b = 2

          local c = 3
          return a+b+c
        end)()

      '';
    };
  };
}
