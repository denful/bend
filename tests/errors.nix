bend: {
  errors."test-label-replaces-left" = {
    expr = (bend.label "bad input" bend.int).get "x";
    expected = bend.left "bad input";
  };

  errors."test-label-passes-right" = {
    expr = (bend.label "bad input" bend.int).get 5;
    expected = bend.right 5;
  };

  errors."test-annotate-wraps-left-with-path-and-got" = {
    expr = (bend.annotate [ "user" "name" ] bend.str).get 42;
    expected = bend.left {
      path = [
        "user"
        "name"
      ];
      got = 42;
    };
  };

  errors."test-annotate-passes-right" = {
    expr = (bend.annotate [ "user" "name" ] bend.str).get "alice";
    expected = bend.right "alice";
  };

  errors."test-annotateWith-custom-error-fn" = {
    expr =
      (bend.annotateWith (path: got: {
        at = path;
        value = got;
      }) [ "x" ] bend.int).get
        "bad";
    expected = bend.left {
      at = [ "x" ];
      value = "bad";
    };
  };

  errors."test-ensure-returns-msg-when-pred-fails" = {
    expr = (bend.ensure (s: s != "") "required" bend.str).get "";
    expected = bend.left "required";
  };

  errors."test-ensure-passes-right-when-pred-passes" = {
    expr = (bend.ensure (s: s != "") "required" bend.str).get "alice";
    expected = bend.right "alice";
  };

  errors."test-ensure-propagates-inner-left" = {
    expr = (bend.ensure (s: s != "") "required" bend.str).get 42;
    expected = bend.left 42;
  };

  errors."test-defaultPathError-shape" = {
    expr = bend.defaultPathError [ "a" "b" ] "bad";
    expected = {
      path = [
        "a"
        "b"
      ];
      got = "bad";
    };
  };

  "pipe-named"."test-unnamed-steps-unchanged" = {
    expr = (bend.pipe [ bend.str ]).get 42;
    expected = bend.left 42;
  };

  "pipe-named"."test-named-step-annotates-left" = {
    expr =
      (bend.pipe [
        {
          name = "age";
          lens = bend.int;
        }
      ]).get
        "bad";
    expected = bend.left {
      path = [ "age" ];
      got = "bad";
    };
  };

  "pipe-named"."test-named-step-passes-right" = {
    expr =
      (bend.pipe [
        {
          name = "age";
          lens = bend.int;
        }
      ]).get
        30;
    expected = bend.right 30;
  };

  "pipe-named"."test-path-accumulates-across-named-steps" = {
    expr =
      (bend.pipe [
        {
          name = "user";
          lens = bend.attr "user";
        }
        {
          name = "name";
          lens = bend.attr "name";
        }
        bend.str
      ]).get
        {
          user = {
            name = 42;
          };
        };
    expected = bend.left 42;
  };

  "pipe-named"."test-named-step-outer-fail-correct-path" = {
    expr =
      (bend.pipe [
        {
          name = "user";
          lens = bend.attr "user";
        }
        {
          name = "name";
          lens = bend.attr "name";
        }
        bend.str
      ]).get
        { };
    expected = bend.left {
      path = [ "user" ];
      got = { };
    };
  };

  "pipe-named"."test-named-step-custom-errorFn" = {
    expr =
      (bend.pipe [
        {
          name = "x";
          lens = bend.int;
          errorFn = path: got: "fail at ${builtins.concatStringsSep "." path}";
        }
      ]).get
        "bad";
    expected = bend.left "fail at x";
  };

  "pipe-named"."test-mixed-named-unnamed-compose" = {
    expr =
      (bend.pipe [
        {
          name = "count";
          lens = bend.attr "count";
        }
        bend.int
        (bend.ensure (n: n > 0) "must be positive" bend.identity)
      ]).get
        { count = -1; };
    expected = bend.left "must be positive";
  };
}
