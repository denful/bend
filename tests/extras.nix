bend: {
  float."test-float-accepts-float" = {
    expr = bend.float.get 1.5;
    expected = bend.right 1.5;
  };
  float."test-float-rejects-int" = {
    expr = bend.float.get 1;
    expected = bend.left 1;
  };

  number."test-number-accepts-int" = {
    expr = bend.number.get 42;
    expected = bend.right 42;
  };
  number."test-number-accepts-float" = {
    expr = bend.number.get 3.14;
    expected = bend.right 3.14;
  };
  number."test-number-rejects-string" = {
    expr = bend.number.get "42";
    expected = bend.left "42";
  };

  nonBlank."test-nonBlank-accepts-non-empty-string" = {
    expr = bend.nonBlank.get "hello";
    expected = bend.right "hello";
  };
  nonBlank."test-nonBlank-rejects-empty-string" = {
    expr = bend.nonBlank.get "";
    expected = bend.left "";
  };
  nonBlank."test-nonBlank-rejects-non-string" = {
    expr = bend.nonBlank.get 42;
    expected = bend.left 42;
  };

  optional."test-nullable-passes-null-as-right-null" = {
    expr = (bend.optional bend.str).get null;
    expected = bend.right null;
  };
  optional."test-nullable-applies-inner-lens-on-non-null" = {
    expr = (bend.optional bend.str).get "hello";
    expected = bend.right "hello";
  };
  optional."test-nullable-propagates-inner-left" = {
    expr = (bend.optional bend.str).get 42;
    expected = bend.left 42;
  };
  optional."test-nullable-set-null-returns-right-null" = {
    expr = (bend.optional bend.str).set "old" null;
    expected = bend.right null;
  };

  attrOr."test-attrOr-returns-value-when-present" = {
    expr = (bend.attrOr "x" 99).get { x = 1; };
    expected = bend.right 1;
  };
  attrOr."test-attrOr-returns-default-when-absent" = {
    expr = (bend.attrOr "x" 99).get { y = 1; };
    expected = bend.right 99;
  };

  mapKey."test-mapKeys-renames-all-keys" = {
    expr = (bend.mapKey (k: k + "_ok")).get {
      a = 1;
      b = 2;
    };
    expected = bend.right {
      a_ok = 1;
      b_ok = 2;
    };
  };
  mapKey."test-mapKeys-empty-attrset" = {
    expr = (bend.mapKey (k: k + "_ok")).get { };
    expected = bend.right { };
  };
  mapKey."test-mapKeys-rejects-non-attrset" = {
    expr = (bend.mapKey (k: k + "_ok")).get "bad";
    expected = bend.left "bad";
  };
}
