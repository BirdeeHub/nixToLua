with builtins; {
  
  mkLuaInline = expr: { __type = "nix-to-lua-inline"; inherit expr; };

  toLua = input: let

    isLuaInline = toCheck:
    if isAttrs toCheck && toCheck ? __type
    then toCheck.__type == "nix-to-lua-inline"
    else false;

    LI2STR = LI: let
        splitter = str: concatMap (x: if isList x then x else []) (split "(.)" str);
        endsWith = acc: if acc == [] then "" else builtins.elemAt acc ((builtins.length acc) - 1);
        parse = str: let
          rm_nl = builtins.replaceStrings [ "\n" ] [ ";" ] str;
          rm_tb = builtins.replaceStrings [ "\t" ] [ " " ] rm_nl;
          strList = splitter rm_tb;
          op = acc: x: let
            lchr = endsWith acc;
            lwasspace = lchr == " " && x == " ";
            lwassemi = lchr == ";" && (x == ";" || x == " ");
            strim = acc == [] && (x == " " || x == ";");
            skip = lwassemi || lwasspace || strim;
            res = if skip then acc else acc ++ [ x ];
          in res;
        in builtins.foldl' op [] strList;
        parsed = parse LI.expr;
        needsRMV = if endsWith parsed == ";" then true else false;
        combined = concatStringsSep "" parsed;
        result = if needsRMV then builtins.substring 0 (builtins.stringLength combined - 1) combined else combined;
      in
      result;

    isDerivation = value: value.type or null == "derivation";

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

    luaEnclose = inString: let
      eqNum = measureLongBois inString;
      eqStr = concatStringsSep "" (genList (_: "=") eqNum);
      bL = "[" + eqStr + "[";
      bR = "]" + eqStr + "]";
    in
    bL + inString + bR;

    doSingleLuaValue = value:
      if value == true then "true"
      else if value == false then "false"
      else if value == null then "nil"
      else if isDerivation value then luaEnclose "${value}"
      else if isList value then "${luaListPrinter value}"
      else if isLuaInline value then LI2STR value
      else if isAttrs value then "${luaTablePrinter value}"
      else luaEnclose (toString value);

    luaTablePrinter = attrSet: let
      luatableformatter = attrSet: let
        nameandstringmap = mapAttrs (n: value: let
            name = "[ " + (luaEnclose "${n}") + " ]";
          in
          "${name} = ${doSingleLuaValue value}") attrSet;
        resultList = attrValues nameandstringmap;
        resultString = concatStringsSep ", " resultList;
      in
      resultString;
      catset = luatableformatter attrSet;
      LuaTable = "{ " + catset + " }";
    in
    LuaTable;

    luaListPrinter = theList: let
      lualistformatter = theList: let
        stringlist = map doSingleLuaValue theList;
        resultString = concatStringsSep ", " stringlist;
      in
      resultString;
      catlist = lualistformatter theList;
      LuaList = "{ " + catlist + " }";
    in
    LuaList;

  in
  doSingleLuaValue input;

}
