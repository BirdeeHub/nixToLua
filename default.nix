with builtins; rec {
  
  mkLuaTableWithMeta = translator: table: # lua
    ''(function(tbl_in)
      return setmetatable(tbl_in, {
        __call = function(_, attrpath)
          local strtable = {}
          if type(attrpath) == "table" then
              strtable = attrpath
          elseif type(attrpath) == "string" then
              for key in attrpath:gmatch("([^%.]+)") do
                  table.insert(strtable, key)
              end
          else
              print("function requires a table of strings or a dot separated string")
              return
          end
          if #strtable == 0 then return nil end
          local tbl = tbl_in
          for _, key in ipairs(strtable) do
            if type(tbl) ~= "table" then
              return nil
            end
            tbl = tbl[key]
          end
          return tbl
        end
      })
    end)(${translator table})'';

  mkLuaInline = expr: { __type = "nix-to-lua-inline"; inherit expr; };

  isLuaInline = toCheck: toCheck.__type or "" == "nix-to-lua-inline" && toCheck ? expr;

  luaResult = LI: if isLuaInline LI then
    "assert(loadstring(${luaEnclose "return ${LI.expr}"}))()"
    else throw "argument to nixToLua.luaResult was not a lua inline expression";

  toLua = toLuaInternal {};

  prettyLua = toLuaInternal { pretty = true; };

  prettyNoModify = toLuaInternal { pretty = true; formatstrings = false; };

  toLuaInternal = {
    pretty ? false,
    indentSize ? 2,
    # adds indenting to multiline strings
    # and multiline lua expressions
    formatstrings ? true, # <-- only active if pretty is true
    ...
  }: input: let

    genStr = str: num: concatStringsSep "" (genList (_: str) num);

    luaToString = LI: "assert(loadstring(${luaEnclose "return ${LI.expr}"}))()";

    luaEnclose = inString: let
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

    nl_spc = level: if pretty == true
      then "\n${genStr " " (level * indentSize)}" else " ";

    doSingleLuaValue = level: value: let
      replacer = str: if pretty && formatstrings then replaceStrings [ "\n" ] [ "${nl_spc level}" ] str else str;
      isDerivation = value: value.type or null == "derivation";
    in
      if value == true then "true"
      else if value == false then "false"
      else if value == null then "nil"
      else if isFloat value || isInt value then toString value
      else if isList value then "${luaListPrinter level value}"
      else if isLuaInline value then replacer (luaToString value)
      else if value ? outPath then luaEnclose "${value.outPath}"
      else if isDerivation value then luaEnclose "${value}"
      else if isAttrs value then "${luaTablePrinter level value}"
      else replacer (luaEnclose (toString value));

    luaTablePrinter = level: attrSet: let
      nameandstringmap = mapAttrs (n: value: let
        name = "[ " + (luaEnclose "${n}") + " ]";
      in
        "${name} = ${doSingleLuaValue (level + 1) value}") attrSet;
      resultList = attrValues nameandstringmap;
      catset = concatStringsSep ",${nl_spc (level + 1)}" resultList;
      LuaTable = "{${nl_spc (level + 1)}" + catset + "${nl_spc level}}";
    in
    LuaTable;

    luaListPrinter = level: theList: let
      stringlist = map (doSingleLuaValue (level + 1)) theList;
      catlist = concatStringsSep ",${nl_spc (level + 1)}" stringlist;
      LuaList = "{${nl_spc (level + 1)}" + catlist + "${nl_spc level}}";
    in
    LuaList;

  in
  doSingleLuaValue 0 input;

}
