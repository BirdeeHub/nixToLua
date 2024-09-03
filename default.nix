with builtins; rec {
  
  mkLuaInline = expr: { __type = "nix-to-lua-inline"; inherit expr; };

  isLuaInline = toCheck:
  if isAttrs toCheck && toCheck ? __type
  then toCheck.__type == "nix-to-lua-inline"
  else false;

  luaResult = LI: if isLuaInline LI then
    "assert(loadstring(${luaEnclose "return ${LI.expr}"}))()"
    else throw "argument to nixToLua.luaResult was not a lua inline expression";

  toLua = toLuaInternal {};

  prettyLua = toLuaInternal { pretty = true; };

  prettyNoModify = toLuaInternal { pretty = true; formatstrings = false; };

  toLuaInternal = {
    pretty ? false,
    # adds indenting to multiline strings
    # and multiline lua expressions
    formatstrings ? true, # <-- only active if pretty is true
    ...
  }: input: let

    luaEnclose = inString: let
      genStr = str: num: concatStringsSep "" (genList (_: str) num);

      measureLongBois = inString: let
        normalize_split = list: filter (x: x != null && x != "")
            (concatMap (x: if isList x then x else [ ]) list);
        splitter = str: normalize_split (split "(\\[=*\\[)|(]=*])" str);
        counter = str: map stringLength (splitter str);
        getMax = str: foldl' (max: x: if x > max then x else max) 0 (counter str);
        getEqSigns = str: (getMax str) - 2;
        longBoiLength = getEqSigns inString;
      in
      if longBoiLength >= 0 then longBoiLength + 1 else 0;

      eqNum = measureLongBois inString;
      eqStr = genStr "=" eqNum;
      bL = "[" + eqStr + "[";
      bR = "]" + eqStr + "]";
    in
    bL + inString + bR;

    nl_spc = level: let
      genStr = str: num: concatStringsSep "" (genList (_: str) num);
    in
    if pretty == true then "\n${genStr " " (level * 2)}" else " ";

    doSingleLuaValue = level: value: let
      replacer = str: if pretty && formatstrings then builtins.replaceStrings [ "\n" ] [ "${nl_spc level}" ] str else str;

      luaToStr = LI: "assert(loadstring(${luaEnclose "return ${LI.expr}"}))()";

      isDerivation = value: value.type or null == "derivation";
    in
      if value == true then "true"
      else if value == false then "false"
      else if value == null then "nil"
      else if isList value then "${luaListPrinter value level}"
      else if isDerivation value then luaEnclose "${value}"
      else if isLuaInline value then replacer (luaToStr value)
      else if isAttrs value then "${luaTablePrinter value level}"
      else replacer (luaEnclose (toString value));

    luaTablePrinter = attrSet: level: let
      luatableformatter = attrSet: let
        nameandstringmap = mapAttrs (n: value: let
            name = "[ " + (luaEnclose "${n}") + " ]";
          in
          "${name} = ${doSingleLuaValue (level + 1) value}") attrSet;
        resultList = attrValues nameandstringmap;
        resultString = concatStringsSep ",${nl_spc (level + 1)}" resultList;
      in
      resultString;
      catset = luatableformatter attrSet;
      LuaTable = "{${nl_spc (level + 1)}" + catset + "${nl_spc level}}";
    in
    LuaTable;

    luaListPrinter = theList: level: let
      lualistformatter = theList: let
        stringlist = map (doSingleLuaValue (level + 1)) theList;
        resultString = concatStringsSep ",${nl_spc (level + 1)}" stringlist;
      in
      resultString;
      catlist = lualistformatter theList;
      LuaList = "{${nl_spc (level + 1)}" + catlist + "${nl_spc level}}";
    in
    LuaList;

  in
  doSingleLuaValue 0 input;

}
