bend: {
  predicate."test-andP-both-pass" = {
    expr = bend.andP (x: x > 0) (x: x < 10) 5;
    expected = true;
  };
  predicate."test-andP-first-fails" = {
    expr = bend.andP (x: x > 0) (x: x < 10) (-1);
    expected = false;
  };
  predicate."test-andP-second-fails" = {
    expr = bend.andP (x: x > 0) (x: x < 10) 15;
    expected = false;
  };
  predicate."test-orP-first-passes" = {
    expr = bend.orP (x: x > 0) (x: x < (-5)) 3;
    expected = true;
  };
  predicate."test-orP-both-fail" = {
    expr = bend.orP (x: x > 10) (x: x < 0) 5;
    expected = false;
  };
  predicate."test-notP-negates" = {
    expr = bend.notP (x: x > 0) (-1);
    expected = true;
  };
  predicate."test-andP-with-validate" = {
    expr = (bend.satisfy (bend.andP (x: x > 0) (x: x < 100))).get 50;
    expected = bend.right 50;
  };
  predicate."test-andP-with-validate-fails" = {
    expr = (bend.satisfy (bend.andP (x: x > 0) (x: x < 100))).get 150;
    expected = bend.left 150;
  };
  predicate."test-orP-with-ensure" = {
    expr =
      (bend.ensure (bend.orP builtins.isString builtins.isInt) "must be string or int" bend.identity).get
        true;
    expected = bend.left "must be string or int";
  };
}
