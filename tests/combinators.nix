bend: {
  eachValue."test-mapValues-validates-all-object-values" = {
    expr =
      let
        lens = bend.eachValue bend.int;
      in
      lens.get {
        x = 1;
        y = 2;
        z = 3;
      };
    expected = bend.right {
      x = 1;
      y = 2;
      z = 3;
    };
  };

  eachValue."test-mapValues-fails-on-invalid-value" = {
    expr =
      let
        lens = bend.eachValue bend.int;
      in
      lens.get {
        x = 1;
        y = "bad";
        z = 3;
      };
    expected = bend.left "bad";
  };

  eachValue."test-mapValues-transforms-values" = {
    expr =
      let
        lens = bend.eachValue (bend.map (x: x * 2) bend.identity);
      in
      lens.get {
        a = 1;
        b = 2;
        c = 3;
      };
    expected = bend.right {
      a = 2;
      b = 4;
      c = 6;
    };
  };

  eachValue."test-mapValues-empty-object" = {
    expr =
      let
        lens = bend.eachValue bend.int;
      in
      lens.get { };
    expected = bend.right { };
  };

  eachValue."test-eachValue-set-applies-lens-set-per-value" = {
    expr =
      (bend.eachValue bend.int).set
        {
          a = 1;
          b = 2;
        }
        {
          a = 10;
          b = 20;
        };
    expected = bend.right {
      a = 10;
      b = 20;
    };
  };
  eachValue."test-eachValue-set-fails-with-evidence-on-bad-value" = {
    expr = (bend.eachValue bend.int).set { a = 1; } { a = "bad"; };
    expected = bend.left { a = bend.left "bad"; };
  };

  zip."test-zip-get-combines-two-focused-values" = {
    expr = (bend.zip (bend.attr "x") (bend.attr "y")).get {
      x = 1;
      y = 2;
    };
    expected = bend.right {
      a = 1;
      b = 2;
    };
  };
  zip."test-zip-get-left-if-first-lens-fails" = {
    expr = (bend.zip (bend.attr "x") (bend.attr "y")).get { y = 2; };
    expected = bend.left { y = 2; };
  };
  zip."test-zip-get-left-if-second-lens-fails" = {
    expr = (bend.zip (bend.attr "x") (bend.attr "y")).get { x = 1; };
    expected = bend.left { x = 1; };
  };
  zip."test-zip-set-writes-both-fields" = {
    expr =
      (bend.zip (bend.attr "x") (bend.attr "y")).set
        {
          x = 0;
          y = 0;
          z = 3;
        }
        {
          a = 10;
          b = 20;
        };
    expected = bend.right {
      x = 10;
      y = 20;
      z = 3;
    };
  };

  each."test-each-all-pass" = {
    expr = (bend.each bend.int).get [
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
  each."test-each-partial-fail-returns-left-with-evidence" = {
    expr = (bend.each bend.int).get [
      1
      "x"
      3
    ];
    expected = bend.left [
      (bend.right 1)
      (bend.left "x")
      (bend.right 3)
    ];
  };
  each."test-each-empty-list" = {
    expr = (bend.each bend.int).get [ ];
    expected = bend.right [ ];
  };
  each."test-each-rejects-non-list" = {
    expr = (bend.each bend.int).get 42;
    expected = bend.left 42;
  };
  each."test-each-all-fail-returns-left-with-evidence" = {
    expr = (bend.each bend.int).get [
      "a"
      "b"
    ];
    expected = bend.left [
      (bend.left "a")
      (bend.left "b")
    ];
  };
  each."test-each-set-all-pass" = {
    expr = (bend.each bend.int).set [ 1 2 3 ] [ 10 20 30 ];
    expected = bend.right [
      10
      20
      30
    ];
  };
  each."test-each-set-length-mismatch-returns-left" = {
    expr = (bend.each bend.int).set [ 1 2 ] [ 10 20 30 ];
    expected = bend.left [
      1
      2
    ];
  };
  each."test-each-set-partial-fail-returns-left-with-evidence" = {
    expr = (bend.each bend.int).set [ 1 2 3 ] [ 10 "bad" 30 ];
    expected = bend.left [
      (bend.right 10)
      (bend.left "bad")
      (bend.right 30)
    ];
  };

  many."test-many-empty-list" = {
    expr = (bend.many bend.int).get [ ];
    expected = bend.right [ ];
  };
  many."test-many-all-pass" = {
    expr = (bend.many bend.int).get [
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
  many."test-many-partial-fail-returns-left-evidence" = {
    expr = (bend.many bend.int).get [
      1
      "x"
    ];
    expected = bend.left [
      (bend.right 1)
      (bend.left "x")
    ];
  };
  many."test-many-set-empty" = {
    expr = (bend.many bend.int).set [ ] [ ];
    expected = bend.right [ ];
  };
  many."test-many-set-all-pass" = {
    expr = (bend.many bend.int).set [ 1 2 ] [ 10 20 ];
    expected = bend.right [
      10
      20
    ];
  };

  some."test-some-empty-fails" = {
    expr = (bend.some bend.int).get [ ];
    expected = bend.left [ ];
  };
  some."test-some-one-element-passes" = {
    expr = (bend.some bend.int).get [ 1 ];
    expected = bend.right [ 1 ];
  };
  some."test-some-multiple-pass" = {
    expr = (bend.some bend.int).get [
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

  atLeast."test-atLeast-below-minimum-fails" = {
    expr = (bend.atLeast 2 bend.int).get [ 1 ];
    expected = bend.left [ 1 ];
  };
  atLeast."test-atLeast-exactly-minimum-passes" = {
    expr = (bend.atLeast 2 bend.int).get [
      1
      2
    ];
    expected = bend.right [
      1
      2
    ];
  };
  atLeast."test-atLeast-above-minimum-passes" = {
    expr = (bend.atLeast 2 bend.int).get [
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
  atLeast."test-atLeast-empty-with-zero-passes" = {
    expr = (bend.atLeast 0 bend.int).get [ ];
    expected = bend.right [ ];
  };

  exactly."test-exactly-correct-length-passes" = {
    expr = (bend.exactly 2 bend.int).get [
      1
      2
    ];
    expected = bend.right [
      1
      2
    ];
  };
  exactly."test-exactly-too-many-fails" = {
    expr = (bend.exactly 2 bend.int).get [
      1
      2
      3
    ];
    expected = bend.left [
      1
      2
      3
    ];
  };
  exactly."test-exactly-too-few-fails" = {
    expr = (bend.exactly 2 bend.int).get [ 1 ];
    expected = bend.left [ 1 ];
  };
  exactly."test-exactly-set-correct-length" = {
    expr = (bend.exactly 2 bend.int).set [ 1 2 ] [ 10 20 ];
    expected = bend.right [
      10
      20
    ];
  };
  exactly."test-exactly-set-wrong-length-fails" = {
    expr = (bend.exactly 2 bend.int).set [ 1 2 3 ] [ 10 20 30 ];
    expected = bend.left [
      1
      2
      3
    ];
  };
}
