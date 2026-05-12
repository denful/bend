bend: {
  int."test-get-integer-returns-right" = {
    expr = bend.int.get 42;
    expected = bend.right 42;
  };

  int."test-get-string-returns-left-string" = {
    expr = bend.int.get "hello";
    expected = bend.left "hello";
  };

  int."test-get-bool-returns-left-bool" = {
    expr = bend.int.get true;
    expected = bend.left true;
  };

  str."test-get-string-returns-right" = {
    expr = bend.str.get "hello";
    expected = bend.right "hello";
  };

  str."test-get-integer-returns-left-integer" = {
    expr = bend.str.get 42;
    expected = bend.left 42;
  };

  bool."test-get-bool-returns-right" = {
    expr = bend.bool.get true;
    expected = bend.right true;
  };

  bool."test-get-integer-returns-left-integer" = {
    expr = bend.bool.get 1;
    expected = bend.left 1;
  };

  list."test-get-list-returns-right" = {
    expr = bend.list.get [
      1
      2
      3
    ];
    expected = bend.right [
      1
      2
      3
    ];
  };

  list."test-get-string-returns-left-string" = {
    expr = bend.list.get "hello";
    expected = bend.left "hello";
  };

  nonEmpty."test-get-empty-list-returns-left-empty-list" = {
    expr = bend.nonEmpty.get [ ];
    expected = bend.left [ ];
  };

  nonEmpty."test-get-singleton-returns-right-head-tail" = {
    expr = bend.nonEmpty.get [ 42 ];
    expected = bend.right {
      head = 42;
      tail = [ ];
    };
  };

  nonEmpty."test-get-multi-returns-right-head-tail" = {
    expr = bend.nonEmpty.get [
      1
      2
      3
    ];
    expected = bend.right {
      head = 1;
      tail = [
        2
        3
      ];
    };
  };

  nonEmpty."test-set-reconstructs-list-from-nonEmpty" = {
    expr = bend.nonEmpty.set [ ] {
      head = 9;
      tail = [
        8
        7
      ];
    };
    expected = bend.right [
      9
      8
      7
    ];
  };

  option."test-get-right-passes-through" = {
    expr = (bend.option 0 bend.int).get 42;
    expected = bend.right 42;
  };

  option."test-get-left-replaced-by-default" = {
    expr = (bend.option 0 bend.int).get "bad";
    expected = bend.right 0;
  };

  option."test-set-unaffected" = {
    expr = (bend.option 0 (bend.attr "n")).set { n = 1; } 99;
    expected = bend.right {
      n = 99;
    };
  };
}
