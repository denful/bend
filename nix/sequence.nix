either: adapt: identity: attr:
let
  sequenceEither =
    eithers:
    builtins.foldl' (
      acc: e:
      if acc ? left then
        acc
      else if e ? left then
        e
      else
        either.mapR (list: list ++ [ e.right ]) acc
    ) (either.right [ ]) eithers;

  indexAttrs =
    keys: vals:
    builtins.listToAttrs (
      builtins.genList (i: {
        name = builtins.elemAt keys i;
        value = builtins.elemAt vals i;
      }) (builtins.length keys)
    );

  sequence = lenses: {
    get = s: sequenceEither (map (lens: lens.get s) lenses);
    set = s: _: either.right s;
  };

  collect = names: {
    get = s: either.mapR (indexAttrs names) (sequenceEither (map (k: (attr k).get s) names));
    set = s: _: either.right s;
  };

  transform =
    validators:
    let
      fieldNames = builtins.attrNames validators;
      validateField =
        name: s:
        let
          r = (attr name).get s;
        in
        if r ? left then r else (validators.${name}).get r.right;
    in
    {
      get =
        s:
        either.mapR (indexAttrs fieldNames) (sequenceEither (map (name: validateField name s) fieldNames));
      set = _: either.right;
    };

  defaultTransformError = field: got: { inherit field got; };

  transformAllWith =
    errorFn: validators:
    let
      fieldNames = builtins.attrNames validators;
      validateField =
        name: s:
        let
          attrResult = (attr name).get s;
        in
        if attrResult ? left then
          either.left (errorFn name attrResult.left)
        else
          let
            valResult = (validators.${name}).get attrResult.right;
          in
          if valResult ? left then
            either.left (errorFn name valResult.left)
          else
            either.right valResult.right;
    in
    {
      get =
        s:
        let
          results = map (name: validateField name s) fieldNames;
          hasErrors = builtins.any (r: r ? left) results;
        in
        if hasErrors then
          either.left (indexAttrs fieldNames results)
        else
          either.right (indexAttrs fieldNames (map (r: r.right) results));
      set = _: either.right;
    };

  transformAll = transformAllWith defaultTransformError;
in
{
  inherit
    sequence
    collect
    transform
    defaultTransformError
    transformAllWith
    transformAll
    ;
}
