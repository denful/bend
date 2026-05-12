bend:
let
  defaultPathError = path: got: { inherit path got; };

  labelWith = bend.lmap;
  label = msg: bend.lmap (_: msg);

  regionWith =
    f:
    bend.lmap (err: {
      context = f err;
      inner = err;
    });
  region =
    ctx:
    bend.lmap (err: {
      context = ctx;
      inner = err;
    });

  annotateWith = errorFn: path: bend.lmap (errorFn path);
  annotate = annotateWith defaultPathError;

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
        bend.left msg;
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
