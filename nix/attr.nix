either: adapt: identity: compose:
let
  attr =
    name:
    adapt identity (s: if s ? ${name} then either.right s.${name} else either.left s) (s: v: {
      right = s // {
        ${name} = v;
      };
    }) either.right;

  path = names: builtins.foldl' (outer: name: compose outer (attr name)) identity names;
in
{
  inherit attr path;
}
