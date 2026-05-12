bend:
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
        bend.mapR (list: list ++ [ e.right ]) acc
    ) (bend.right [ ]) eithers;

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
    set = s: _: bend.right s;
  };

  collect = names: {
    get = s: bend.mapR (indexAttrs names) (sequenceEither (map (k: (bend.attr k).get s) names));
    set = s: _: bend.right s;
  };

  transform =
    validators:
    let
      fieldNames = builtins.attrNames validators;
      validateField =
        name: s:
        let
          r = (bend.attr name).get s;
        in
        if r ? left then r else (validators.${name}).get r.right;
    in
    {
      get =
        s: bend.mapR (indexAttrs fieldNames) (sequenceEither (map (name: validateField name s) fieldNames));
      set = _: bend.right;
    };

  defaultTransformError = field: got: { inherit field got; };

  transformAllWith =
    errorFn: validators:
    let
      fieldNames = builtins.attrNames validators;
      validateField =
        name: s:
        let
          attrResult = (bend.attr name).get s;
        in
        if attrResult ? left then
          bend.left (errorFn name attrResult.left)
        else
          let
            valResult = (validators.${name}).get attrResult.right;
          in
          if valResult ? left then bend.left (errorFn name valResult.left) else bend.right valResult.right;
    in
    {
      get =
        s:
        let
          results = map (name: validateField name s) fieldNames;
          hasErrors = builtins.any (r: r ? left) results;
        in
        if hasErrors then
          bend.left (indexAttrs fieldNames results)
        else
          bend.right (indexAttrs fieldNames (map (r: r.right) results));
      set = _: bend.right;
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
