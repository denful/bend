either: adapt: defaultPathError:
let
  identity = {
    get = either.right;
    set = _s: b: b;
  };

  compose = outer: inner: adapt inner outer.get outer.set either.right;

  # pipe: accepts lens | { name; lens } | { name; lens; errorFn }
  # Named steps auto-annotate left with accumulated path.
  # Plain lens steps pass through unchanged (backward compatible).
  pipe =
    steps:
    let
      go =
        acc: step:
        let
          isNamed = builtins.isAttrs step && step ? lens;
          innerLens = if isNamed then step.lens else step;
          path = acc.path ++ (if isNamed then [ step.name ] else [ ]);
          errorFn = if isNamed then step.errorFn or defaultPathError else null;
          wrapped =
            if isNamed then
              {
                get =
                  s:
                  let
                    r = innerLens.get s;
                  in
                  if r ? left then { left = errorFn path r.left; } else r;
                set = innerLens.set;
              }
            else
              innerLens;
        in
        {
          inherit path;
          lens = compose acc.lens wrapped;
        };
      result = builtins.foldl' go {
        path = [ ];
        lens = identity;
      } steps;
    in
    result.lens;

  parse = fmap: lens: adapt lens (s: either.right s) (s: v: v) fmap;

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
