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
          # Named steps get their own errorFn (or default); unnamed steps that
          # immediately follow a named step inherit the accumulated path.
          shouldAnnotate = isNamed || acc.prevWasNamed;
          errorFn = if isNamed then step.errorFn or defaultPathError else defaultPathError;
          effectivePath = if isNamed then path else acc.path;
          wrapped =
            if shouldAnnotate then
              {
                get =
                  s:
                  let
                    r = innerLens.get s;
                  in
                  if r ? left then { left = errorFn effectivePath r.left; } else r;
                set = innerLens.set;
              }
            else
              innerLens;
        in
        {
          inherit path;
          prevWasNamed = isNamed;
          lens = compose acc.lens wrapped;
        };
      result = builtins.foldl' go { path = [ ]; prevWasNamed = false; lens = identity; } steps;
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
