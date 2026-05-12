lens: from: back: refine: {
  get =
    t:
    let
      s = from t;
      a = lens.get s.right;
    in
    if s ? right then if a ? right then refine a.right else a else s;

  set =
    t: b:
    let
      s = from t;
      r = lens.set s.right b;
    in
    if s ? right then if r ? right then back t r.right else r else s;
}
