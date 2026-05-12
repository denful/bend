either: adapt: identity: attr:
let
  index =
    n:
    adapt identity (s: either.right s) (s: v: s) (
      l:
      if builtins.isList l && builtins.length l > n && n >= 0 then
        either.right (builtins.elemAt l n)
      else
        either.left l
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
            either.mapR (acc: acc // { ${name} = fieldResult.right; }) accEither
      ) (either.right { }) (builtins.attrNames obj);
    set = obj: newValues: newValues;
  };
in
{
  inherit
    index
    mapValues
    ;
}
