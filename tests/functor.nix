bend: {
  functor."test-bend-as-function-calls-apply" = {
    expr = bend ({ x, y }: x + y) {
      x = 10;
      y = 32;
    };
    expected = bend.right 42;
  };

  functor."test-bend-functor-with-three-args" = {
    expr =
      bend
        (
          {
            a,
            b,
            c,
          }:
          a + b + c
        )
        {
          a = 1;
          b = 2;
          c = 3;
        };
    expected = bend.right 6;
  };

  functor."test-bend-functor-missing-arg-returns-left" = {
    expr = bend ({ x, y }: x + y) { x = 10; };
    expected = bend.left { x = 10; };
  };

  functor."test-bend-chained-two-levels" = {
    expr = bend ({ x }: x) ({ y }: y) {
      x = {
        y = 22;
      };
    };
    expected = bend.right 22;
  };

  functor."test-bend-chained-three-levels" = {
    expr = bend ({ a }: a) ({ b }: b) ({ c }: c) {
      a = {
        b = {
          c = 99;
        };
      };
    };
    expected = bend.right 99;
  };

  functor."test-bend-chained-missing-inner-key-returns-left" = {
    expr = bend ({ x }: x) ({ y }: y) {
      x = {
        z = 22;
      };
    };
    expected = bend.left { z = 22; };
  };

  functor."test-bend-chained-missing-outer-key-returns-left" = {
    expr = bend ({ x }: x) ({ y }: y) { z = 1; };
    expected = bend.left { z = 1; };
  };

  functor."test-bend-chained-with-extra-keys-ignored" = {
    expr = bend ({ x }: x) ({ y }: y) {
      x = {
        y = 5;
        extra = 99;
      };
    };
    expected = bend.right 5;
  };

  bifunctor."test-bimap-maps-right" = {
    expr = (bend.bimap (_: "err") (x: x * 2) bend.int).get 5;
    expected = bend.right 10;
  };

  bifunctor."test-bimap-maps-left" = {
    expr = (bend.bimap (_: "err") (x: x * 2) bend.int).get "bad";
    expected = bend.left "err";
  };

  bifunctor."test-lmap-maps-left-only" = {
    expr = (bend.lmap (_: "replaced") bend.int).get "bad";
    expected = bend.left "replaced";
  };

  bifunctor."test-lmap-passes-right-unchanged" = {
    expr = (bend.lmap (_: "replaced") bend.int).get 42;
    expected = bend.right 42;
  };

  bifunctor."test-rmap-maps-right-only" = {
    expr = (bend.rmap (x: x + 1) bend.int).get 5;
    expected = bend.right 6;
  };

  bifunctor."test-rmap-passes-left-unchanged" = {
    expr = (bend.rmap (x: x + 1) bend.int).get "bad";
    expected = bend.left "bad";
  };

  bifunctor."test-bimap-set-delegates-to-inner" = {
    expr = (bend.bimap (_: "err") (x: x) (bend.attr "x")).set {
      x = 1;
      y = 2;
    } 99;
    expected = bend.right {
      x = 99;
      y = 2;
    };
  };
}
