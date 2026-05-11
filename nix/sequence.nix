either: adapt: identity: attr:
let
  # Fold list of Either into Either of list; short-circuits on first left
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

  # Collect list of lenses applied to same input into Either of list
  sequence = lenses: {
    get = s: sequenceEither (map (lens: lens.get s) lenses);
    set = s: _: s;
  };

  # Extract named fields from attrset into new attrset; left if any missing
  collect =
    names:
    let
      toAttrs =
        vals:
        builtins.listToAttrs (
          builtins.genList (i: {
            name = builtins.elemAt names i;
            value = builtins.elemAt vals i;
          }) (builtins.length names)
        );
    in
    {
      get =
        s:
        let
          r = sequenceEither (map (k: (attr k).get s) names);
        in
        if r ? left then r else either.right (toAttrs r.right);
      set = s: _: s;
    };

  # Apply per-field validator lenses; returns validated attrset or first left
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
      toAttrs =
        vals:
        builtins.listToAttrs (
          builtins.genList (i: {
            name = builtins.elemAt fieldNames i;
            value = builtins.elemAt vals i;
          }) (builtins.length fieldNames)
        );
    in
    {
      get =
        s:
        let
          r = sequenceEither (map (name: validateField name s) fieldNames);
        in
        if r ? left then r else either.right (toAttrs r.right);
      set = _: b: b;
    };
in
{
  inherit sequence collect transform;
}
