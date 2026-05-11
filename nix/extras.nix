either: adapt: identity: attr:
let
  # Focus on list element by index: out of bounds → left [], present → right value
  index =
    n:
    adapt identity (s: either.right s) (s: v: s) (
      l:
      if builtins.isList l && builtins.length l > n && n >= 0 then
        either.right (builtins.elemAt l n)
      else
        either.left l
    );

  # Apply lens to each value in object: validates all values, returns transformed object
  # Returns left on first field that fails validation
  mapValues = lens: {
    get =
      obj:
      let
        fieldNames = builtins.attrNames obj;
        results = builtins.foldl' (
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
        ) (either.right { }) fieldNames;
      in
      results;

    set = obj: newValues: newValues;
  };
in
{
  inherit
    index
    mapValues
    ;
}
