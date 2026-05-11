# Lens-level bifunctor: map left and/or right branches of lens.get
# set always delegates to inner lens unchanged
let
  bimap = fLeft: fRight: lens: {
    get =
      s:
      let
        r = lens.get s;
      in
      if r ? right then { right = fRight r.right; } else { left = fLeft r.left; };
    set = lens.set;
  };

  lmap = f: bimap f (x: x);

  rmap = f: bimap (x: x) f;
in
{
  inherit bimap lmap rmap;
}
