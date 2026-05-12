bend: {
  integration."test-integration-pipe-attr-nonEmpty-map-extracts-head" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "items")
          bend.nonEmpty
          (bend.map (ne: ne.head) bend.identity)
        ];
      in
      lens.get {
        items = [
          10
          20
          30
        ];
      };
    expected = bend.right 10;
  };

  integration."test-nonEmpty-left-short-circuits-map" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "items")
          bend.nonEmpty
          (bend.map (ne: ne.head) bend.identity)
        ];
      in
      lens.get { items = [ ]; };
    expected = bend.left [ ];
  };

  integration."test-integration-attr-left-short-circuits-entire-pipe" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "items")
          bend.nonEmpty
        ];
      in
      lens.get { other = 1; };
    expected = bend.left { other = 1; };
  };

  integration."test-integration-pipe-attr-str-validates-non-empty-string" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "name")
          bend.str
          (bend.satisfy (s: s != ""))
        ];
      in
      lens.get { name = "alice"; };
    expected = bend.right "alice";
  };

  integration."test-integration-validate-left-carries-original-value" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "name")
          bend.str
          (bend.satisfy (s: s != ""))
        ];
      in
      lens.get { name = ""; };
    expected = bend.left "";
  };

  integration."test-integration-swap-works-on-int-failure-path" = {
    expr = bend.swap (bend.int.get "hello");
    expected = bend.right "hello";
  };

  integration."test-integration-option-absorbs-failure-in-pipe" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "count")
          (bend.option 0 bend.int)
        ];
      in
      lens.get { count = "bad"; };
    expected = bend.right 0;
  };

  integration."test-integration-path-int-parses-nested-integer" = {
    expr =
      (bend.compose (bend.path [
        "config"
        "timeout"
      ]) bend.int).get
        {
          config = {
            timeout = 30;
          };
        };
    expected = bend.right 30;
  };

  integration."test-integration-path-int-left-on-wrong-type" = {
    expr =
      (bend.compose (bend.path [
        "config"
        "timeout"
      ]) bend.int).get
        {
          config = {
            timeout = "thirty";
          };
        };
    expected = bend.left "thirty";
  };

  integration."test-integration-set-round-trip-through-composed-lens" = {
    expr =
      let
        lens = bend.pipe [
          (bend.attr "a")
          (bend.attr "b")
        ];
      in
      lens.set {
        a = {
          b = 1;
          c = 2;
        };
        d = 3;
      } 99;
    expected = bend.right {
      a = {
        b = 99;
        c = 2;
      };
      d = 3;
    };
  };

  integration."test-integration-nonEmpty-set-reconstructs-inside-pipe" = {
    expr =
      let
        lens = bend.compose (bend.attr "items") bend.nonEmpty;
      in
      lens.set { items = [ ]; } {
        head = 1;
        tail = [
          2
          3
        ];
      };
    expected = bend.right {
      items = [
        1
        2
        3
      ];
    };
  };
}
