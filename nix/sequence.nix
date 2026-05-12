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
    set = s: _: s;
  };

  collect = names: {
    get =
      s:
      let
        r = sequenceEither (map (k: (attr k).get s) names);
      in
      if r ? left then r else either.right (indexAttrs names r.right);
    set = s: _: s;
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
        let
          r = sequenceEither (map (name: validateField name s) fieldNames);
        in
        if r ? left then r else either.right (indexAttrs fieldNames r.right);
      set = _: b: b;
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
          errors = builtins.filter (r: r ? left) results;
        in
        if errors != [ ] then
          either.left (map (r: r.left) errors)
        else
          either.right (indexAttrs fieldNames (map (r: r.right) results));
      set = _: b: b;
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
