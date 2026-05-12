bend:
let
  option = def: lens: {
    get =
      s:
      let
        e = lens.get s;
      in
      if e ? right then e else bend.right def;
    set = lens.set;
  };

  over =
    f: lens: s:
    let
      r = lens.get s;
    in
    if r ? right then lens.set s (f r.right) else r;

  getOr =
    def: lens: s:
    let
      r = lens.get s;
    in
    if r ? right then r.right else def;

  when = pred: lens: {
    get = s: if pred s then lens.get s else bend.right s;
    set = s: v: if pred s then lens.set s v else bend.right s;
  };

  unless = pred: when (s: !(pred s));
in
{
  inherit
    option
    over
    getOr
    when
    unless
    ;
}
