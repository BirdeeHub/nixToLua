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
      ];
      "]=====]-!'.thing4" = "couch is for scratching";
    };
  };
}
