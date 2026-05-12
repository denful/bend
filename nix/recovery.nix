either:
let
  recover = f: lens: {
    get =
      s:
      let
        r = lens.get s;
      in
      if r ? right then r else f r.left;
    set = lens.set;
  };

  alt = lensA: lensB: {
    get =
      s:
      let
        r = lensA.get s;
      in
      if r ? right then r else lensB.get s;
    set =
      s: v:
      let
        r = lensA.get s;
      in
      if r ? right then lensA.set s v else lensB.set s v;
  };

  oneOf = lenses: builtins.foldl' alt (builtins.head lenses) (builtins.tail lenses);
in
{
  inherit recover alt oneOf;
}
