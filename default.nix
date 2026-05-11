let
  either = import ./nix/either.nix;
  adapt = import ./nix/adapt.nix;
  transformLib = import ./nix/transform.nix;
  errorsLib = import ./nix/errors.nix transformLib.lmap;
  core = import ./nix/core.nix either adapt errorsLib.defaultPathError;
  attrLib = import ./nix/attr.nix either adapt core.identity core.compose;
  parsers = import ./nix/parsers.nix either adapt core.parse core.identity;
  combinators = import ./nix/combinators.nix either;
  sequenceLib = import ./nix/sequence.nix either adapt core.identity attrLib.attr;
  applyLib = import ./nix/apply.nix either adapt core.identity;
  extrasLib = import ./nix/extras.nix either adapt core.identity attrLib.attr;

  bend = rec {
    inherit adapt;

    inherit (either)
      right
      left
      swap
      chain
      mapR
      mapL
      ;

    inherit (core)
      identity
      compose
      pipe
      parse
      focus
      ;

    inherit (attrLib) attr path;

    inherit (parsers)
      map
      validate
      int
      str
      bool
      list
      nonEmpty
      ;

    inherit (combinators) withDefault;

    inherit (sequenceLib)
      sequence
      collect
      transform
      ;

    inherit (applyLib) apply;

    inherit (extrasLib)
      index
      mapValues
      ;

    inherit (transformLib) bimap lmap rmap;

    inherit (errorsLib)
      defaultPathError
      labelWith
      label
      regionWith
      region
      annotateWith
      annotate
      ensure
      ;

    # chainable wraps a lens so each call with a function composes another apply,
    # and a call with data (non-function) triggers get
    chainable =
      lens:
      lens
      // {
        __functor =
          _: arg: if builtins.isFunction arg then chainable (compose lens (apply arg)) else lens.get arg;
      };

    __functor = _: fn: chainable (apply fn);
  };
in
bend
