either: adapt:
let
  # Base lens: returns any value on right, identity on set
  identity = {
    get = either.right;
    set = _s: b: b;
  };

  # Compose two lenses: thread inner through outer
  compose = outer: inner: adapt inner outer.get outer.set either.right;

  # Fold lenses left-to-right (compose all into single lens)
  pipe = lenses: builtins.foldl' compose identity lenses;

  # Covariant refinement: apply fmap to focused value, structural passthrough on set
  parse = fmap: lens: adapt lens (s: either.right s) (s: v: v) fmap;

  # Lift pure get/set functions into a lens
  focus = getF: setF: adapt identity (s: either.right (getF s)) setF either.right;
in
{
  inherit
    identity
    compose
    pipe
    parse
    focus
    ;
}
