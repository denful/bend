either: adapt: parse: identity:
let
  # Pure value transform: apply function to right value
  map = f: parse (a: either.right (f a));

  # Predicate parser: pred true → right same value, false → left same value
  validate = pred: parse (a: if pred a then either.right a else either.left a);

  # Type parsers: check runtime type, carry original value on left
  int = parse (a: if builtins.isInt a then either.right a else either.left a) identity;
  str = parse (a: if builtins.isString a then either.right a else either.left a) identity;
  bool = parse (a: if builtins.isBool a then either.right a else either.left a) identity;
  list = parse (a: if builtins.isList a then either.right a else either.left a) identity;

  # NonEmpty list parser: empty → left [], non-empty → right { head; tail }
  nonEmpty = adapt identity (s: either.right s) (_: ne: [ ne.head ] ++ ne.tail) (
    l:
    if l == [ ] then
      either.left l
    else
      either.right {
        head = builtins.head l;
        tail = builtins.tail l;
      }
  );

  # Predicate combinators: pure boolean functions
  andP = p: q: v: p v && q v;
  orP = p: q: v: p v || q v;
  notP = p: v: !(p v);
in
{
  inherit
    map
    validate
    int
    str
    bool
    list
    nonEmpty
    andP
    orP
    notP
    ;
}
