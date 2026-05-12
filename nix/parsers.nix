either: adapt: parse: identity:
let
  map = f: parse (a: either.right (f a));

  validateWith = pred: parse (a: if pred a then either.right a else either.left a);

  validate = pred: validateWith pred identity;

  typeParser = validate;

  int = typeParser builtins.isInt;
  str = typeParser builtins.isString;
  bool = typeParser builtins.isBool;
  list = typeParser builtins.isList;

  nonEmpty = adapt identity either.right (_: ne: either.right ([ ne.head ] ++ ne.tail)) (
    l:
    if l == [ ] then
      either.left l
    else
      either.right {
        head = builtins.head l;
        tail = builtins.tail l;
      }
  );

  andP =
    p: q: v:
    p v && q v;
  orP =
    p: q: v:
    p v || q v;
  notP = p: v: !(p v);
in
{
  inherit
    map
    validate
    validateWith
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
