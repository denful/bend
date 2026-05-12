bend:
let
  identity = {
    get = bend.right;
    set = _: bend.right;
  };

  compose = outer: inner: bend.adapt inner outer.get outer.set bend.right;

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
                errorFn = step.errorFn or bend.defaultPathError;
              in
              {
                get = s: bend.mapL (errorFn path) (innerLens.get s);
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

  parse = refine: lens: bend.adapt lens bend.right (_: v: v) refine;

  focus =
    getF: setF: bend.adapt identity (s: bend.right (getF s)) (s: v: bend.right (setF s v)) bend.right;

  iso = f: g: focus f (_: g);

  prism = build: match: {
    get = match;
    set = _: v: bend.right (build v);
  };
in
{
  inherit
    identity
    compose
    pipe
    parse
    focus
    iso
    prism
    ;
}
