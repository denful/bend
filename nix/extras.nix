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
in
{
  inherit index mapValues;
}
