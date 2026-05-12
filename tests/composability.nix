bend: {
  adapt-partial."test-adapt-with-partial-from-back" = {
    expr =
      let
        # Partially apply adapt with from and back functions
        # Returns lens -> lens transformer
        adaptValidator = bend.adapt
          (s: if builtins.isInt s then bend.right s else bend.left s)
          (_s: _v: { })
          (x: bend.right (x * 2));
        # Apply to identity lens
        lens = adaptValidator bend.identity;
      in
      lens.get 5;
    expected = bend.right 10;
  };

  adapt-partial."test-adapt-partial-with-different-lenses" = {
    expr =
      let
        # Validator that transforms refine function
        validator = bend.adapt
          bend.right
          (_s: _v: { })
          (x: bend.right (x + 100));
        # Apply to different extraction lenses
        lens1 = validator bend.identity;
        lens2 = validator (bend.attr "x");
      in
      {
        one = lens1.get 5;
        two = lens2.get { x = 3; y = 10; };
      };
    expected = {
      one = bend.right 105;
      two = bend.right 103;
    };
  };

  over-partial."test-over-transforms-reusable" = {
    expr =
      let
        # Partially apply over with function
        # Returns lens -> s -> result
        double = bend.over (x: x * 2);
        # Use with different lenses
        doubleX = double (bend.attr "x");
        doubleArray0 = double (bend.index 0);
      in
      {
        x = doubleX { x = 5; y = 1; };
        arr = doubleArray0 [ 10 20 30 ];
      };
    expected = {
      x = bend.right { x = 10; y = 1; };
      arr = bend.right [ 20 20 30 ];
    };
  };

  lens-composition."test-compose-with-type-validators" = {
    expr =
      let
        # Compose path extraction with type validation
        pathInt = bend.compose (bend.attr "x") bend.int;
      in
      pathInt.get { x = 42; };
    expected = bend.right 42;
  };

  lens-composition."test-compose-chained-with-path" = {
    expr =
      let
        # Use path for multi-level access instead of nested compose
        # path handles the composition internally
        deep = bend.path [ "level1" "level2" "level3" ];
      in
      deep.get {
        level1 = {
          level2 = {
            level3 = "found";
          };
        };
      };
    expected = bend.right "found";
  };

  lens-transformer-chain."test-when-predicate-curried" = {
    expr =
      let
        # Partially apply when for reuse
        whenInt = bend.when builtins.isInt;
        lens1 = whenInt bend.int;
        lens2 = whenInt (bend.attr "value");
      in
      {
        passInt = lens1.get 5;
        failStr = lens1.get "hello";
        passAttr = lens2.get { value = 99; };
      };
    expected = {
      passInt = bend.right 5;
      failStr = bend.right "hello";
      passAttr = bend.right { value = 99; };
    };
  };

  lens-transformer-chain."test-option-with-default" = {
    expr =
      let
        # Create a validator with default value
        optionalInt = bend.option 0 bend.int;
        # Use with another lens
        optionalXValue = bend.option { x = 0; } (bend.attr "x");
      in
      {
        validInt = optionalInt.get 42;
        invalidInt = optionalInt.get "bad";
        validAttr = optionalXValue.get { x = 7; };
        invalidAttr = optionalXValue.get { y = 3; };
      };
    expected = {
      validInt = bend.right 42;
      invalidInt = bend.right 0;
      validAttr = bend.right 7;
      invalidAttr = bend.right { x = 0; };
    };
  };

  point-free."test-parse-with-refine-no-intermediate-bindings" = {
    expr =
      # Point-free: compose parsers without naming intermediate steps
      (bend.parse (x: bend.right (x + 1)) bend.int).get 5;
    expected = bend.right 6;
  };

  point-free."test-pipe-without-intermediate-variables" = {
    expr =
      # Pipe multiple steps without intermediate lens variables
      (bend.pipe [
        (bend.attr "user")
        (bend.attr "name")
        bend.str
      ]).get
        {
          user = {
            name = "Alice";
            age = 30;
          };
        };
    expected = bend.right "Alice";
  };

  higher-order."test-map-combinator-on-validator" = {
    expr =
      let
        # Compose map (which reorders to take function first)
        # with a parser to transform values
        parseIntDoubled = bend.map (x: x * 2) bend.int;
      in
      parseIntDoubled.get 21;
    expected = bend.right 42;
  };

  higher-order."test-getOr-with-partial-application" = {
    expr =
      let
        # Create a partial getOr with default
        intOrZero = bend.getOr 0 bend.int;
        strOrEmpty = bend.getOr "" bend.str;
      in
      {
        validInt = intOrZero 42;
        invalidInt = intOrZero "bad";
        validStr = strOrEmpty "hello";
        invalidStr = strOrEmpty 123;
      };
    expected = {
      validInt = 42;
      invalidInt = 0;
      validStr = "hello";
      invalidStr = "";
    };
  };
}
