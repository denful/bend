either: adapt: defaultPathError:
let
  identity = {
    get = either.right;
    set = _: either.right;
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
                get = s: either.mapL (errorFn path) (innerLens.get s);
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

  parse = refine: lens: adapt lens either.right (_: v: v) refine;

  focus =
    getF: setF: adapt identity (s: either.right (getF s)) (s: v: either.right (setF s v)) either.right;
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
