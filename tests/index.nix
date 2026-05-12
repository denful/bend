bend: {
  index."test-index-zero-gets-first-element" = {
    expr =
      let
        lens = bend.index 0;
      in
      lens.get [
        10
        20
        30
      ];
    expected = bend.right 10;
  };

  index."test-index-two-gets-third-element" = {
    expr =
      let
        lens = bend.index 2;
      in
      lens.get [
        10
        20
        30
      ];
    expected = bend.right 30;
  };

  index."test-index-out-of-bounds-returns-left" = {
    expr =
      let
        lens = bend.index 5;
      in
      lens.get [
        10
        20
        30
      ];
    expected = bend.left [
      10
      20
      30
    ];
  };

  index."test-index-negative-returns-left" = {
    expr =
      let
        lens = bend.index (-1);
      in
      lens.get [
        10
        20
        30
      ];
    expected = bend.left [
      10
      20
      30
    ];
  };

  index."test-index-set-writes-value-at-position-0" = {
    expr = (bend.index 0).set [ 1 2 3 ] 99;
    expected = bend.right [ 99 2 3 ];
  };
  index."test-index-set-writes-value-at-position-1" = {
    expr = (bend.index 1).set [ 1 2 3 ] 99;
    expected = bend.right [ 1 99 3 ];
  };
  index."test-index-set-out-of-bounds-returns-left" = {
    expr = (bend.index 5).set [ 1 2 3 ] 99;
    expected = bend.left [ 1 2 3 ];
  };
}
