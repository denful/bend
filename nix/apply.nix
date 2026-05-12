either: adapt: identity:
let
  apply =
    fn:
    let
      args = builtins.functionArgs fn;
    in
    adapt identity (
      s:
      if builtins.all (k: s ? ${k}) (builtins.attrNames args) then
        either.right (builtins.intersectAttrs args s)
      else
        either.left s
    ) (s: _: s) (subset: either.right (fn subset));
in
{
  inherit apply;
}
