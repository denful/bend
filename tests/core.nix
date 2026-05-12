bend: {
  attr."test-get-present-key-returns-right-value" = {
    expr = (bend.attr "x").get {
      x = 42;
      y = 1;
    };
    expected = bend.right 42;
  };

  attr."test-get-missing-key-returns-left-source-attrset" = {
    expr = (bend.attr "x").get { y = 1; };
    expected = bend.left { y = 1; };
  };

  attr."test-set-updates-key-preserves-siblings" = {
    expr = (bend.attr "x").set {
      x = 1;
      y = 2;
    } 99;
    expected = bend.right {
      x = 99;
      y = 2;
    };
  };

  attr."test-set-on-nested-preserves-outer-siblings" = {
    expr = (bend.attr "a").set {
      a = {
        b = 1;
      };
      c = 3;
    } { b = 99; };
    expected = bend.right {
      a = {
        b = 99;
      };
      c = 3;
    };
  };

  path."test-get-two-level-nested-attrset" = {
    expr =
      (bend.path [
        "a"
        "b"
      ]).get
        {
          a = {
            b = 42;
          };
        };
    expected = bend.right 42;
  };

  path."test-get-missing-outer-key-returns-left-source" = {
    expr =
      (bend.path [
        "a"
        "b"
      ]).get
        { z = 1; };
    expected = bend.left { z = 1; };
  };

  path."test-set-two-level-updates-inner-preserves-siblings" = {
    expr =
      (bend.path [
        "a"
        "b"
      ]).set
        {
          a = {
            b = 1;
            c = 2;
          };
          d = 3;
        }
        99;
    expected = bend.right {
      a = {
        b = 99;
        c = 2;
      };
      d = 3;
    };
  };

  path."test-empty-behaves-as-identity" = {
    expr = (bend.path [ ]).get { x = 7; };
    expected = bend.right { x = 7; };
  };

  compose."test-get-threads-inner-through-outer" = {
    expr = (bend.compose (bend.attr "a") (bend.attr "b")).get {
      a = {
        b = 99;
      };
    };
    expected = bend.right 99;
  };

  compose."test-set-writes-at-correct-depth" = {
    expr = (bend.compose (bend.attr "a") (bend.attr "b")).set {
      a = {
        b = 1;
        c = 2;
      };
      d = 3;
    } 99;
    expected = bend.right {
      a = {
        b = 99;
        c = 2;
      };
      d = 3;
    };
  };

  map."test-get-transforms-right-value" = {
    expr = (bend.map (x: x * 2) bend.identity).get 5;
    expected = bend.right 10;
  };

  map."test-get-passes-left-unchanged" = {
    expr =
      let
        failing = bend.adapt (_: bend.left 99) (_: _: { }) bend.right bend.identity;
      in
      (bend.map (x: x * 2) failing).get 5;
    expected = bend.left 99;
  };

  map."test-set-is-structural-passthrough" = {
    expr = (bend.map (x: x * 2) (bend.attr "n")).set { n = 1; } 99;
    expected = {
      n = 99;
    };
  };

  satisfy."test-get-pred-pass-returns-right-same-value" = {
    expr = (bend.satisfy (x: x > 0)).get 5;
    expected = bend.right 5;
  };

  satisfy."test-get-pred-fail-returns-left-same-value" = {
    expr = (bend.satisfy (x: x > 0)).get (-1);
    expected = bend.left (-1);
  };
}
