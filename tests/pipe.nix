bend: {
  pipe."test-empty-equals-identity" = {
    expr = (bend.pipe [ ]).get { x = 1; };
    expected = bend.right { x = 1; };
  };

  parse."test-applies-refine-on-right" = {
    expr = (bend.parse (a: bend.right (a * 2)) bend.identity).get 5;
    expected = bend.right 10;
  };

  parse."test-passes-left-unchanged" = {
    expr =
      let
        failing = bend.adapt bend.identity (_: bend.left 99) (_: _: { }) bend.right;
      in
      (bend.parse (a: bend.right (a * 2)) failing).get 5;
    expected = bend.left 99;
  };

  focus."test-lifts-pure-get-set-into-lens" = {
    expr = (bend.focus (s: s.x) (s: v: s // { x = v; })).get {
      x = 7;
      y = 2;
    };
    expected = bend.right 7;
  };

  focus."test-set-updates-correctly" = {
    expr = (bend.focus (s: s.x) (s: v: s // { x = v; })).set {
      x = 1;
      y = 2;
    } 99;
    expected = bend.right {
      x = 99;
      y = 2;
    };
  };
}
