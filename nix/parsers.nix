bend:
let
  map = f: bend.parse (a: bend.right (f a));

  satisfyWith = pred: bend.parse (a: if pred a then bend.right a else bend.left a);

  satisfy = pred: satisfyWith pred bend.identity;

  int = satisfy builtins.isInt;
  str = satisfy builtins.isString;
  bool = satisfy builtins.isBool;
  list = satisfy builtins.isList;
  float = satisfy builtins.isFloat;
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
    (satisfy (s: s != ""))
  ];

  optional = lens: {
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
    satisfy
    satisfyWith
    int
    str
    bool
    list
    float
    number
    nonEmpty
    nonBlank
    optional
    andP
    orP
    notP
    ;
}
