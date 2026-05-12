bend: {
  identity."test-get-returns-right-s" = {
    expr = bend.identity.get { x = 1; };
    expected = bend.right { x = 1; };
  };

  identity."test-identity-set-returns-b-ignoring-s" = {
    expr = bend.identity.set { x = 1; } 99;
    expected = bend.right 99;
  };

  adapt."test-from-right-inner-get-receives-extracted-value" = {
    expr =
      let
        lens = bend.adapt (s: bend.right s.x) (_s: _v: { x = 0; }) bend.right bend.identity;
      in
      lens.get { x = 42; };
    expected = bend.right 42;
  };

  adapt."test-from-left-short-circuits-before-inner-get" = {
    expr =
      let
        lens = bend.adapt (_: bend.left "nope") (_s: _v: { }) bend.right bend.identity;
      in
      lens.get 5;
    expected = bend.left "nope";
  };

  adapt."test-refine-transforms-right-value" = {
    expr =
      let
        lens = bend.adapt bend.right (_s: _v: { }) (a: bend.right (a * 2)) bend.identity;
      in
      lens.get 5;
    expected = bend.right 10;
  };

  adapt."test-refine-left-short-circuits-outer-refine-not-called" = {
    expr =
      let
        inner = bend.adapt bend.right (_s: _v: { }) (_: bend.left "inner failed") bend.identity;
        chained = bend.adapt bend.right (_s: _v: { }) (_: bend.right "should not reach") inner;
      in
      chained.get 5;
    expected = bend.left "inner failed";
  };

  adapt."test-back-writes-inner-back-on-set" = {
    expr =
      let
        lens = bend.adapt (s: bend.right s.x) (s: v: s // { x = v; }) bend.right bend.identity;
      in
      lens.set {
        x = 1;
        y = 2;
      } 99;
    expected = {
      x = 99;
      y = 2;
    };
  };

  adapt."test-from-left-short-circuits-set" = {
    expr =
      let
        lens = bend.adapt (_: bend.left "no access") (_s: _v: { }) bend.right bend.identity;
      in
      lens.set { } 99;
    expected = bend.left "no access";
  };
}
