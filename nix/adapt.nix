lens: cmap: smap: fmap: {
  get =
    t:
    let
      e_s = cmap t;
    in
    if e_s ? right then
      let
        e_a = lens.get e_s.right;
      in
      if e_a ? right then fmap e_a.right else e_a
    else
      e_s;

  set = t: b: smap t (lens.set (cmap t).right b);
}
