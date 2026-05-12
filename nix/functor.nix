bend: {
  chainable =
    let
      go =
        lens:
        lens
        // {
          __functor =
            _: arg: if builtins.isFunction arg then go (bend.compose lens (bend.apply arg)) else lens.get arg;
        };
    in
    go;

  __functor = _: fn: bend.chainable (bend.apply fn);
}
