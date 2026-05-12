either: adapt: defaultPathError:
let
  identity = {
    get = either.right;
    set = _s: b: { right = b; };
  };

  compose = outer: inner: adapt inner outer.get outer.set either.right;

  pipe =
    steps:
    let
      go =
        acc: step:
        let
          isNamed = builtins.isAttrs step && step ? lens;
          innerLens = if isNamed then step.lens else step;
          path = acc.path ++ (if isNamed then [ step.name ] else [ ]);
          wrapped =
            if isNamed then
              let
                errorFn = step.errorFn or defaultPathError;
              in
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

  parse = refine: lens: adapt lens (s: either.right s) (s: v: v) refine;

  focus =
    getF: setF: adapt identity (s: either.right (getF s)) (s: v: { right = setF s v; }) either.right;
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
