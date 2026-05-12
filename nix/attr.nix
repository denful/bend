bend:
let
  attr =
    name:
    bend.adapt (s: if s ? ${name} then bend.right s.${name} else bend.left s) (
      s: v: bend.right (s // { ${name} = v; })
    ) bend.right bend.identity;

  attrOr = name: def: bend.option def (attr name);

  path = names: builtins.foldl' (outer: name: bend.compose outer (attr name)) bend.identity names;
in
{
  inherit attr attrOr path;
}
