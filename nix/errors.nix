lmap:
let
  defaultPathError = path: got: { inherit path got; };

  labelWith = f: lmap f;
  label = msg: lmap (_: msg);

  regionWith =
    f:
    lmap (err: {
      context = f err;
      inner = err;
    });
  region =
    ctx:
    lmap (err: {
      context = ctx;
      inner = err;
    });

  annotateWith = errorFn: path: lmap (got: errorFn path got);
  annotate = annotateWith defaultPathError;

  # ensure: validate pred on right value; left msg if fails; propagates inner left unchanged
  ensure = pred: msg: lens: {
    get =
      s:
      let
        r = lens.get s;
      in
      if r ? left then
        r
      else if pred r.right then
        r
      else
        { left = msg; };
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
