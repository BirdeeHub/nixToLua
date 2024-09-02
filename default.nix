with builtins; {
  
  mkLuaInline = expr: { __type = "nix-to-lua-inline"; inherit expr; };

  toLua = input: let

    isLuaInline = toCheck:
    if builtins.isAttrs toCheck && toCheck ? __type
    then toCheck.__type == "nix-to-lua-inline"
    else false;

    isDerivation = value: value.type or null == "derivation";

    measureLongBois = inString: let
      normalize_split = list: builtins.filter (x: x != null && x != "")
          (builtins.concatMap (x: if builtins.isList x then x else [ ]) list);
      splitter = str: normalize_split (builtins.split "(\\[=*\\[)|(]=*])" str);
      counter = str: builtins.map builtins.stringLength (splitter str);
      getMax = str: builtins.foldl' (max: x: if x > max then x else max) 0 (counter str);
      getEqSigns = str: (getMax str) - 2;
    in
    getEqSigns inString;

    luaEnclose = inString: let
      eqInString = measureLongBois inString;
      eqNum = if eqInString >= 0 then eqInString + 1 else 0;
      eqStr = builtins.concatStringsSep "" (builtins.genList (_: "=") eqNum);
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
      else if isLuaInline value then toString value.expr
      else if isAttrs value then "${luaTablePrinter value}"
      else luaEnclose (toString value);

    luaTablePrinter = attrSet: let
      luatableformatter = attrSet: let
        nameandstringmap = mapAttrs (n: value: let
            name = if isLuaInline n
              then builtins.trace (n.expr) (builtins.throw "dynamic lua values not allowed in attr names from nix")
              else "[ " + (luaEnclose "${n}") + " ]";
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
