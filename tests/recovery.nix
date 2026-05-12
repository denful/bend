bend: {
  recovery = {
    "test-recover-calls-f-on-left" = {
      expr = (bend.recover (_: bend.right 0) bend.int).get "bad";
      expected = bend.right 0;
    };
    "test-recover-passes-right-unchanged" = {
      expr = (bend.recover (_: bend.right 0) bend.int).get 5;
      expected = bend.right 5;
    };
    "test-recover-can-return-left" = {
      expr = (bend.recover (v: bend.left "still bad") bend.str).get 42;
      expected = bend.left "still bad";
    };
    "test-alt-returns-first-right" = {
      expr = (bend.alt bend.str bend.int).get "hello";
      expected = bend.right "hello";
    };
    "test-alt-falls-back-to-second" = {
      expr = (bend.alt bend.str bend.int).get 42;
      expected = bend.right 42;
    };
    "test-alt-left-when-both-fail" = {
      expr = (bend.alt bend.str bend.int).get true;
      expected = bend.left true;
    };
    "test-choice-first-right-wins" = {
      expr =
        (bend.choice [
          bend.str
          bend.int
          bend.bool
        ]).get
          42;
      expected = bend.right 42;
    };
    "test-choice-left-when-all-fail" = {
      expr =
        (bend.choice [
          bend.str
          bend.int
        ]).get
          true;
      expected = bend.left true;
    };
    "test-alt-set-through-winning-branch" = {
      expr = (bend.alt (bend.attr "x") (bend.attr "y")).set {
        x = 1;
        y = 2;
      } 99;
      expected = bend.right {
        x = 99;
        y = 2;
      };
    };
  };
}
