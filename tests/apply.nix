bend: {
  apply."test-apply-extracts-two-attributes" = {
    expr =
      let
        lens = bend.apply ({ x, y }: x + y);
      in
      lens.get {
        x = 10;
        y = 32;
      };
    expected = bend.right 42;
  };

  apply."test-apply-missing-attribute-returns-left" = {
    expr =
      let
        lens = bend.apply ({ x, y }: x + y);
      in
      lens.get { x = 10; };
    expected = bend.left { x = 10; };
  };

  apply."test-apply-ignores-extra-attributes" = {
    expr =
      let
        lens = bend.apply ({ x, y }: x + y);
      in
      lens.get {
        x = 10;
        y = 32;
        z = 999;
      };
    expected = bend.right 42;
  };

  apply."test-apply-single-argument" = {
    expr =
      let
        lens = bend.apply ({ name }: "hello " + name);
      in
      lens.get { name = "world"; };
    expected = bend.right "hello world";
  };

  apply."test-apply-with-validation" = {
    expr =
      let
        lens = bend.compose (bend.apply ({ x, y }: x + y)) (bend.satisfy (n: n > 20));
      in
      lens.get {
        x = 15;
        y = 10;
      };
    expected = bend.right 25;
  };

  apply."test-apply-validation-fails" = {
    expr =
      let
        lens = bend.compose (bend.apply ({ x, y }: x + y)) (bend.satisfy (n: n > 30));
      in
      lens.get {
        x = 15;
        y = 10;
      };
    expected = bend.left 25;
  };

  apply."test-apply-three-arguments" = {
    expr =
      let
        lens = bend.apply (
          {
            a,
            b,
            c,
          }:
          a + b + c
        );
      in
      lens.get {
        a = 1;
        b = 2;
        c = 3;
      };
    expected = bend.right 6;
  };

  apply."test-apply-object-construction" = {
    expr =
      let
        lens = bend.apply (
          {
            first,
            last,
            age,
          }:
          {
            inherit first last age;
          }
        );
      in
      lens.get {
        first = "Alice";
        last = "Smith";
        age = 30;
      };
    expected = bend.right {
      first = "Alice";
      last = "Smith";
      age = 30;
    };
  };
}
