bend:
let
  map = f: bend.parse (a: bend.right (f a));

  validateWith = pred: bend.parse (a: if pred a then bend.right a else bend.left a);

  validate = pred: validateWith pred bend.identity;

  int = validate builtins.isInt;
  str = validate builtins.isString;
  bool = validate builtins.isBool;
  list = validate builtins.isList;
  float = validate builtins.isFloat;
  number = bend.alt int float;

  nonEmpty = bend.adapt bend.identity bend.right (_: ne: bend.right ([ ne.head ] ++ ne.tail)) (
    l:
    if l == [ ] then
      bend.left l
    else
      bend.right {
        head = builtins.head l;
        tail = builtins.tail l;
      }
  );

  nonBlank = bend.pipe [
    str
    (validate (s: s != ""))
  ];

  nullable = lens: {
    get = s: if s == null then bend.right null else lens.get s;
    set = s: v: if v == null then bend.right null else lens.set s v;
  };

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
    float
    number
    nonEmpty
    nonBlank
    nullable
    andP
    orP
    notP
    ;
}
