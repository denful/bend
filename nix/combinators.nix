either:
let
  # Absorb left branch, replacing with default: partial lens → total lens
  withDefault = def: lens: {
    get =
      s:
      let
        e = lens.get s;
      in
      if e ? right then e else either.right def;
    set = lens.set;
  };
in
{
  inherit withDefault;
}
