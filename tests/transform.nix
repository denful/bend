bend: {
  record."test-transform-validates-all-fields" = {
    expr =
      let
        lens = bend.record {
          x = bend.int;
          y = bend.str;
          z = bend.list;
        };
      in
      lens.get {
        x = 1;
        y = "hello";
        z = [
          1
          2
          3
        ];
      };
    expected = bend.right {
      x = 1;
      y = "hello";
      z = [
        1
        2
        3
      ];
    };
  };

  record."test-transform-fails-on-first-invalid-field" = {
    expr =
      let
        lens = bend.record {
          x = bend.int;
          y = bend.str;
          z = bend.list;
        };
      in
      lens.get {
        x = "bad";
        y = "hello";
        z = [
          1
          2
          3
        ];
      };
    expected = bend.left "bad";
  };

  record."test-transform-fails-on-middle-field" = {
    expr =
      let
        lens = bend.record {
          x = bend.int;
          y = bend.str;
          z = bend.list;
        };
      in
      lens.get {
        x = 1;
        y = 123;
        z = [
          1
          2
          3
        ];
      };
    expected = bend.left 123;
  };

  record."test-transform-single-field" = {
    expr =
      let
        lens = bend.record { x = bend.int; };
      in
      lens.get {
        x = 42;
        extra = "ignored";
      };
    expected = bend.right { x = 42; };
  };

  record."test-transform-with-custom-validator" = {
    expr =
      let
        lens = bend.record {
          x = bend.int;
          y = bend.satisfyWith (s: builtins.stringLength s > 3) bend.str;
        };
      in
      lens.get {
        x = 5;
        y = "hello";
      };
    expected = bend.right {
      x = 5;
      y = "hello";
    };
  };

  record."test-transform-custom-validator-fails" = {
    expr =
      let
        lens = bend.record {
          x = bend.int;
          y = bend.satisfyWith (s: builtins.stringLength s > 3) bend.str;
        };
      in
      lens.get {
        x = 5;
        y = "hi";
      };
    expected = bend.left "hi";
  };

  recordAll."test-valid-input-returns-right-attrset" = {
    expr =
      (bend.recordAll {
        name = bend.str;
        age = bend.int;
      }).get
        {
          name = "alice";
          age = 30;
        };
    expected = bend.right {
      name = "alice";
      age = 30;
    };
  };
  recordAll."test-single-invalid-field-returns-left-per-field" = {
    expr =
      (bend.recordAll {
        name = bend.str;
        age = bend.int;
      }).get
        {
          name = "alice";
          age = "thirty";
        };
    expected = bend.left {
      name = bend.right "alice";
      age = bend.left {
        field = "age";
        got = "thirty";
      };
    };
  };
  recordAll."test-all-invalid-fields-per-field-eithers" = {
    expr =
      (bend.recordAll {
        name = bend.str;
        age = bend.int;
      }).get
        {
          name = 1;
          age = "thirty";
        };
    expected = bend.left {
      age = bend.left {
        field = "age";
        got = "thirty";
      };
      name = bend.left {
        field = "name";
        got = 1;
      };
    };
  };
  recordAll."test-missing-field-counted-as-error" = {
    expr =
      (bend.recordAll {
        name = bend.str;
        age = bend.int;
      }).get
        { name = "alice"; };
    expected = bend.left {
      age = bend.left {
        field = "age";
        got = {
          name = "alice";
        };
      };
      name = bend.right "alice";
    };
  };
  recordAll."test-transformAllWith-custom-error-shape" = {
    expr =
      (bend.recordAllWith (f: g: "${f}:${builtins.typeOf g}") {
        name = bend.str;
        age = bend.int;
      }).get
        {
          name = "alice";
          age = "thirty";
        };
    expected = bend.left {
      name = bend.right "alice";
      age = bend.left "age:string";
    };
  };
  recordAll."test-defaultRecordError-shape" = {
    expr = bend.defaultRecordError "age" 30;
    expected = {
      field = "age";
      got = 30;
    };
  };
}
