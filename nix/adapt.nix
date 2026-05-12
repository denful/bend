_: {
  adapt =
    from: back: refine: lens:
    let
      run =
        t: op: finish:
        let
          s = from t;
          r = op s.right;
        in
        if s ? right then if r ? right then finish r.right else r else s;
    in
    {
      get = t: run t lens.get refine;
      set = t: b: run t (s: lens.set s b) (back t);
    };
}
