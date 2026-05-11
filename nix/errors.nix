# Error shaping combinators — all built on lmap
# label: replace left with static message
# region: wrap left with outer context (stackable)
# annotate: wrap left with {path; got} (circe cursor pattern)
# ensure: inline predicate check returning labeled error
lmap:
let
  defaultPathError = path: got: { inherit path got; };

  labelWith = f: lmap f;
  label = msg: lmap (_: msg);

  regionWith = f: lmap (err: { context = f err; inner = err; });
  region = ctx: lmap (err: { context = ctx; inner = err; });

  annotateWith = errorFn: path: lmap (got: errorFn path got);
  annotate = annotateWith defaultPathError;

  # ensure: validate pred on right value; left msg if fails; propagates inner left unchanged
  ensure =
    pred: msg: lens:
    {
      get =
        s:
        let
          r = lens.get s;
        in
        if r ? left then r else if pred r.right then r else { left = msg; };
      set = lens.set;
    };
in
{
  inherit
    defaultPathError
    labelWith
    label
    regionWith
    region
    annotateWith
    annotate
    ensure
    ;
}
