# Single combinator: adapt a lens with focus transformation and value refinement
# lens  - inner lens to adapt
# cmap  - contravariant focus: extract inner from outer (can fail)
# smap  - write-back: merge inner result into outer (pure, never fails)
# fmap  - covariant parse: refine focused value (can fail)
# Result: new lens focusing through outer structure into inner value
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
