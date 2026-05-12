lens: cmap: smap: fmap: {
  get =
    t:
    let
      s = cmap t;
      a = lens.get s.right;
    in
    if s ? right then if a ? right then fmap a.right else a else s;

  set = t: b: smap t (lens.set (cmap t).right b);
}
