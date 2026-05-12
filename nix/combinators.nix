bend:
let
  withDefault = def: lens: {
    get =
      s:
      let
        e = lens.get s;
      in
      if e ? right then e else bend.right def;
    set = lens.set;
  };
in
{
  inherit withDefault;
}
