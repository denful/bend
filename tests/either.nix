bend: {
  either."test-right-produces-right-attrset" = {
    expr = bend.right 42;
    expected = {
      right = 42;
    };
  };
  either."test-left-produces-left-attrset" = {
    expr = bend.left "x";
    expected = {
      left = "x";
    };
  };
  either."test-swap-right-becomes-left" = {
    expr = bend.swap (bend.right 1);
    expected = {
      left = 1;
    };
  };
  either."test-swap-left-becomes-right" = {
    expr = bend.swap (bend.left 1);
    expected = {
      right = 1;
    };
  };
  either."test-chain-applies-f-on-right" = {
    expr = bend.chain (x: bend.right (x * 2)) (bend.right 5);
    expected = {
      right = 10;
    };
  };
  either."test-chain-passes-left-unchanged" = {
    expr = bend.chain (x: bend.right (x * 2)) (bend.left 5);
    expected = {
      left = 5;
    };
  };
  either."test-mapR-transforms-right" = {
    expr = bend.mapR (x: x + 1) (bend.right 5);
    expected = {
      right = 6;
    };
  };
  either."test-mapR-passes-left-unchanged" = {
    expr = bend.mapR (x: x + 1) (bend.left 5);
    expected = {
      left = 5;
    };
  };
  either."test-mapL-transforms-left" = {
    expr = bend.mapL (x: x + 1) (bend.left 5);
    expected = {
      left = 6;
    };
  };
  either."test-mapL-passes-right-unchanged" = {
    expr = bend.mapL (x: x + 1) (bend.right 5);
    expected = {
      right = 5;
    };
  };
}
