let
  bend =
    (import ./nix/either.nix bend)
    // (import ./nix/adapt.nix bend)
    // (import ./nix/transform.nix bend)
    // (import ./nix/errors.nix bend)
    // (import ./nix/core.nix bend)
    // (import ./nix/attr.nix bend)
    // (import ./nix/parsers.nix bend)
    // (import ./nix/combinators.nix bend)
    // (import ./nix/sequence.nix bend)
    // (import ./nix/apply.nix bend)
    // (import ./nix/extras.nix bend)
    // (import ./nix/recovery.nix bend)
    // (import ./nix/debug.nix bend)
    // {
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
    };
in
bend
