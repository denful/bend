bend: {
  over."test-over-modifies-focused-value" = {
    expr = bend.over (n: n * 2) (bend.attr "x") {
      x = 5;
      y = 1;
    };
    expected = bend.right {
      x = 10;
      y = 1;
    };
  };
  over."test-over-propagates-left" = {
    expr = bend.over (n: n * 2) (bend.attr "x") { y = 1; };
    expected = bend.left { y = 1; };
  };

  getOr."test-getOr-returns-raw-right-value" = {
    expr = bend.getOr 0 bend.int 42;
    expected = 42;
  };
  getOr."test-getOr-returns-default-on-left" = {
    expr = bend.getOr 0 bend.int "bad";
    expected = 0;
  };

  when."test-when-applies-lens-if-pred-passes" = {
    expr = (bend.when builtins.isInt bend.int).get 5;
    expected = bend.right 5;
  };
  when."test-when-passes-through-if-pred-fails" = {
    expr = (bend.when builtins.isInt bend.int).get "hello";
    expected = bend.right "hello";
  };
  when."test-when-set-applies-if-pred-passes" = {
    expr = (bend.when (s: s ? x) (bend.attr "x")).set { x = 1; } 99;
    expected = bend.right { x = 99; };
  };
  when."test-when-set-skips-if-pred-fails" = {
    expr = (bend.when (s: s ? x) (bend.attr "x")).set { y = 2; } 99;
    expected = bend.right { y = 2; };
  };

  unless."test-unless-passes-through-if-pred-passes" = {
    expr = (bend.unless builtins.isInt bend.str).get 5;
    expected = bend.right 5;
  };
  unless."test-unless-applies-lens-if-pred-fails" = {
    expr = (bend.unless builtins.isInt bend.str).get "hello";
    expected = bend.right "hello";
  };

  iso."test-iso-get-applies-forward-fn" = {
    expr = (bend.iso (x: x + 1) (x: x - 1)).get 5;
    expected = bend.right 6;
  };
  iso."test-iso-set-applies-backward-fn-ignores-source" = {
    expr = (bend.iso (x: x + 1) (x: x - 1)).set 999 10;
    expected = bend.right 9;
  };

  prism."test-prism-get-right-on-matching-variant" = {
    expr =
      let
        gitUrl = bend.prism (url: {
          type = "git";
          inherit url;
        }) (s: if s.type or "" == "git" then bend.right s.url else bend.left s);
      in
      gitUrl.get {
        type = "git";
        url = "https://example.com";
      };
    expected = bend.right "https://example.com";
  };
  prism."test-prism-get-left-on-wrong-variant" = {
    expr =
      let
        gitUrl = bend.prism (url: {
          type = "git";
          inherit url;
        }) (s: if s.type or "" == "git" then bend.right s.url else bend.left s);
      in
      gitUrl.get {
        type = "path";
        path = "/foo";
      };
    expected = bend.left {
      type = "path";
      path = "/foo";
    };
  };
  prism."test-prism-set-builds-variant-ignoring-source" = {
    expr =
      let
        gitUrl = bend.prism (url: {
          type = "git";
          inherit url;
        }) (s: if s.type or "" == "git" then bend.right s.url else bend.left s);
      in
      gitUrl.set { } "https://new.url";
    expected = bend.right {
      type = "git";
      url = "https://new.url";
    };
  };
}
