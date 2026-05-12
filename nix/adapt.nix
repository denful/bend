lens: cmap: smap: fmap: {
  get =
    t:
    let
      s = cmap t;
      a = lens.get s.right;
    in
    if s ? right then if a ? right then fmap a.right else a else s;

  set =
    t: b:
    let
      s = cmap t;
      r = lens.set s.right b;
    in
    if s ? right then if r ? right then smap t r.right else r else s;
}
