bend:
let
  defaultPathError = path: got: { inherit path got; };

  label = msg: bend.lmap (_: msg);

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
    label
    annotateWith
    annotate
    ensure
    ;
}
