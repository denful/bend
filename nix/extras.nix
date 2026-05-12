bend:
let
  index =
    n:
    bend.adapt bend.identity bend.right (s: _: bend.right s) (
      l:
      if builtins.isList l && builtins.length l > n && n >= 0 then
        bend.right (builtins.elemAt l n)
      else
        bend.left l
    );

  mapValues = lens: {
    get =
      obj:
      builtins.foldl' (
        accEither: name:
        if accEither ? left then
          accEither
        else
          let
            fieldResult = lens.get obj.${name};
          in
          if fieldResult ? left then
            fieldResult
          else
            bend.mapR (acc: acc // { ${name} = fieldResult.right; }) accEither
      ) (bend.right { }) (builtins.attrNames obj);
    set = _: bend.right;
  };

  mapList = lens: {
    get =
      s:
      if !builtins.isList s then
        bend.left s
      else
        builtins.foldl' (
          acc: elem:
          if acc ? left then
            acc
          else
            let
              r = lens.get elem;
            in
            if r ? left then r else bend.mapR (list: list ++ [ r.right ]) acc
        ) (bend.right [ ]) s;
    set = _: bend.right;
  };

  each = lens: {
    get =
      s:
      if !builtins.isList s then
        bend.left s
      else
        let
          results = builtins.filter (r: r ? right) (map lens.get s);
        in
        bend.right (map (r: r.right) results);
    set = _: bend.right;
  };

  mapKeys = f: {
    get =
      s:
      if !builtins.isAttrs s then
        bend.left s
      else
        bend.right (
          builtins.listToAttrs (
            map (k: {
              name = f k;
              value = s.${k};
            }) (builtins.attrNames s)
          )
        );
    set = _: bend.right;
  };
in
{
  inherit
    index
    mapValues
    mapList
    each
    mapKeys
    ;
}
