bend:
let
  apply =
    fn:
    let
      args = builtins.functionArgs fn;
    in
    bend.adapt bend.identity (
      s:
      if builtins.all (k: s ? ${k}) (builtins.attrNames args) then
        bend.right (builtins.intersectAttrs args s)
      else
        bend.left s
    ) (s: _: s) (subset: bend.right (fn subset));
in
{
  inherit apply;
}
