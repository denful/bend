bend:
let
  apply =
    fn:
    let
      args = builtins.functionArgs fn;
    in
    bend.adapt (
      s:
      if builtins.all (k: s ? ${k}) (builtins.attrNames args) then
        bend.right (builtins.intersectAttrs args s)
      else
        bend.left s
    ) (s: _: s) (subset: bend.right (fn subset)) bend.identity;
in
{
  inherit apply;
}
