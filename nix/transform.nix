bend:
let
  bimap = fLeft: fRight: lens: {
    get =
      s:
      let
        r = lens.get s;
      in
      if r ? right then bend.right (fRight r.right) else bend.left (fLeft r.left);
    set = lens.set;
  };

  lmap = f: bimap f (x: x);
  rmap = f: bimap (x: x) f;
in
{
  inherit bimap lmap rmap;
}
