either: adapt: identity: compose:
let
  # Focus on an attribute: present → right value, missing → left source attrset
  attr =
    name:
    adapt identity (s: if s ? ${name} then either.right s.${name} else either.left s) (
      s: v: s // { ${name} = v; }
    ) either.right;

  # Focus through nested attributes: compose attr lenses for each level
  path = names: builtins.foldl' (outer: name: compose outer (attr name)) identity names;
in
{
  inherit attr path;
}
