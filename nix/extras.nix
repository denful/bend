bend:
let
  index =
    n:
    let
      inBounds = l: builtins.isList l && builtins.length l > n && n >= 0;
    in
    {
      get = l: if inBounds l then bend.right (builtins.elemAt l n) else bend.left l;
      set =
        l: v:
        if inBounds l then
          bend.right (builtins.genList (i: if i == n then v else builtins.elemAt l i) (builtins.length l))
        else
          bend.left l;
    };

  eachValue = lens: {
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
    set =
      obj: vs:
      if !builtins.isAttrs obj || !builtins.isAttrs vs then
        bend.left obj
      else
        let
          keys = builtins.attrNames obj;
          results = map (k: lens.get vs.${k}) keys;
          hasError = builtins.any (r: r ? left) results;
        in
        if hasError then
          bend.left (
            builtins.listToAttrs (
              builtins.genList (i: {
                name = builtins.elemAt keys i;
                value = builtins.elemAt results i;
              }) (builtins.length keys)
            )
          )
        else
          bend.right (
            builtins.listToAttrs (
              builtins.genList (i: {
                name = builtins.elemAt keys i;
                value = (builtins.elemAt results i).right;
              }) (builtins.length keys)
            )
          );
  };

  each = lens: {
    get =
      s:
      if !builtins.isList s then
        bend.left s
      else
        let
          results = map lens.get s;
          hasError = builtins.any (r: r ? left) results;
        in
        if hasError then bend.left results else bend.right (map (r: r.right) results);
    set =
      s: vs:
      if !builtins.isList s || !builtins.isList vs || builtins.length s != builtins.length vs then
        bend.left s
      else
        let
          n = builtins.length s;
          results = builtins.genList (i: lens.get (builtins.elemAt vs i)) n;
          hasError = builtins.any (r: r ? left) results;
        in
        if hasError then bend.left results else bend.right (map (r: r.right) results);
  };

  atLeast = n: lens: {
    get =
      s:
      if !builtins.isList s then
        bend.left s
      else if builtins.length s < n then
        bend.left s
      else
        (each lens).get s;
    set =
      s: vs:
      if !builtins.isList s then
        bend.left s
      else if builtins.length s < n then
        bend.left s
      else
        (each lens).set s vs;
  };

  some = lens: atLeast 1 lens;

  many = lens: {
    get =
      s:
      if !builtins.isList s then
        bend.left s
      else if s == [ ] then
        bend.right [ ]
      else
        (each lens).get s;
    set =
      s: vs:
      if !builtins.isList s || !builtins.isList vs then
        bend.left s
      else if s == [ ] && vs == [ ] then
        bend.right [ ]
      else
        (each lens).set s vs;
  };

  exactly = n: lens: {
    get =
      s:
      if !builtins.isList s then
        bend.left s
      else if builtins.length s != n then
        bend.left s
      else
        (each lens).get s;
    set =
      s: vs:
      if !builtins.isList s then
        bend.left s
      else if builtins.length s != n then
        bend.left s
      else
        (each lens).set s vs;
  };

  mapKey = f: {
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
    eachValue
    each
    atLeast
    some
    many
    exactly
    mapKey
    ;
}
