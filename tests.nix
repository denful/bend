let
  bend = import ./.;
in
{
  nix-unit = {
    either."test-right-produces-right-attrset" = {
      expr = bend.right 42;
      expected = {
        right = 42;
      };
    };
    either."test-left-produces-left-attrset" = {
      expr = bend.left "x";
      expected = {
        left = "x";
      };
    };
    either."test-swap-right-becomes-left" = {
      expr = bend.swap (bend.right 1);
      expected = {
        left = 1;
      };
    };
    either."test-swap-left-becomes-right" = {
      expr = bend.swap (bend.left 1);
      expected = {
        right = 1;
      };
    };
    either."test-chain-applies-f-on-right" = {
      expr = bend.chain (x: bend.right (x * 2)) (bend.right 5);
      expected = {
        right = 10;
      };
    };
    either."test-chain-passes-left-unchanged" = {
      expr = bend.chain (x: bend.right (x * 2)) (bend.left 5);
      expected = {
        left = 5;
      };
    };
    either."test-mapR-transforms-right" = {
      expr = bend.mapR (x: x + 1) (bend.right 5);
      expected = {
        right = 6;
      };
    };
    either."test-mapR-passes-left-unchanged" = {
      expr = bend.mapR (x: x + 1) (bend.left 5);
      expected = {
        left = 5;
      };
    };
    either."test-mapL-transforms-left" = {
      expr = bend.mapL (x: x + 1) (bend.left 5);
      expected = {
        left = 6;
      };
    };
    either."test-mapL-passes-right-unchanged" = {
      expr = bend.mapL (x: x + 1) (bend.right 5);
      expected = {
        right = 5;
      };
    };

    identity."test-get-returns-right-s" = {
      expr = bend.identity.get { x = 1; };
      expected = bend.right { x = 1; };
    };

    identity."test-identity-set-returns-b-ignoring-s" = {
      expr = bend.identity.set { x = 1; } 99;
      expected = 99;
    };

    adapt."test-cmap-right-inner-get-receives-extracted-value" = {
      expr =
        let
          lens = bend.adapt bend.identity (s: bend.right s.x) (_s: _v: { x = 0; }) bend.right;
        in
        lens.get { x = 42; };
      expected = bend.right 42;
    };

    adapt."test-cmap-left-short-circuits-before-inner-get" = {
      expr =
        let
          lens = bend.adapt bend.identity (_: bend.left "nope") (_s: _v: { }) bend.right;
        in
        lens.get 5;
      expected = bend.left "nope";
    };

    adapt."test-fmap-transforms-right-value" = {
      expr =
        let
          lens = bend.adapt bend.identity bend.right (_s: _v: { }) (a: bend.right (a * 2));
        in
        lens.get 5;
      expected = bend.right 10;
    };

    adapt."test-fmap-left-short-circuits-outer-fmap-not-called" = {
      expr =
        let
          inner = bend.adapt bend.identity bend.right (_s: _v: { }) (_: bend.left "inner failed");
          chained = bend.adapt inner bend.right (_s: _v: { }) (_: bend.right "should not reach");
        in
        chained.get 5;
      expected = bend.left "inner failed";
    };

    adapt."test-smap-writes-inner-back-on-set" = {
      expr =
        let
          lens = bend.adapt bend.identity (s: bend.right s.x) (s: v: s // { x = v; }) bend.right;
        in
        lens.set {
          x = 1;
          y = 2;
        } 99;
      expected = {
        x = 99;
        y = 2;
      };
    };

    pipe."test-empty-equals-identity" = {
      expr = (bend.pipe [ ]).get { x = 1; };
      expected = bend.right { x = 1; };
    };

    parse."test-applies-fmap-on-right" = {
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
      expected = {
        x = 99;
        y = 2;
      };
    };

    attr."test-get-present-key-returns-right-value" = {
      expr = (bend.attr "x").get {
        x = 42;
        y = 1;
      };
      expected = bend.right 42;
    };

    attr."test-get-missing-key-returns-left-source-attrset" = {
      expr = (bend.attr "x").get { y = 1; };
      expected = bend.left { y = 1; };
    };

    attr."test-set-updates-key-preserves-siblings" = {
      expr = (bend.attr "x").set {
        x = 1;
        y = 2;
      } 99;
      expected = {
        x = 99;
        y = 2;
      };
    };

    attr."test-set-on-nested-preserves-outer-siblings" = {
      expr = (bend.attr "a").set {
        a = {
          b = 1;
        };
        c = 3;
      } { b = 99; };
      expected = {
        a = {
          b = 99;
        };
        c = 3;
      };
    };

    path."test-get-two-level-nested-attrset" = {
      expr =
        (bend.path [
          "a"
          "b"
        ]).get
          {
            a = {
              b = 42;
            };
          };
      expected = bend.right 42;
    };

    path."test-get-missing-outer-key-returns-left-source" = {
      expr =
        (bend.path [
          "a"
          "b"
        ]).get
          { z = 1; };
      expected = bend.left { z = 1; };
    };

    path."test-set-two-level-updates-inner-preserves-siblings" = {
      expr =
        (bend.path [
          "a"
          "b"
        ]).set
          {
            a = {
              b = 1;
              c = 2;
            };
            d = 3;
          }
          99;
      expected = {
        a = {
          b = 99;
          c = 2;
        };
        d = 3;
      };
    };

    path."test-empty-behaves-as-identity" = {
      expr = (bend.path [ ]).get { x = 7; };
      expected = bend.right { x = 7; };
    };

    compose."test-get-threads-inner-through-outer" = {
      expr = (bend.compose (bend.attr "a") (bend.attr "b")).get {
        a = {
          b = 99;
        };
      };
      expected = bend.right 99;
    };

    compose."test-set-writes-at-correct-depth" = {
      expr = (bend.compose (bend.attr "a") (bend.attr "b")).set {
        a = {
          b = 1;
          c = 2;
        };
        d = 3;
      } 99;
      expected = {
        a = {
          b = 99;
          c = 2;
        };
        d = 3;
      };
    };

    map."test-get-transforms-right-value" = {
      expr = (bend.map (x: x * 2) bend.identity).get 5;
      expected = bend.right 10;
    };

    map."test-get-passes-left-unchanged" = {
      expr =
        let
          failing = bend.adapt bend.identity (_: bend.left 99) (_: _: { }) bend.right;
        in
        (bend.map (x: x * 2) failing).get 5;
      expected = bend.left 99;
    };

    map."test-set-is-structural-passthrough" = {
      expr = (bend.map (x: x * 2) (bend.attr "n")).set { n = 1; } 99;
      expected = {
        n = 99;
      };
    };

    validate."test-get-pred-pass-returns-right-same-value" = {
      expr = (bend.validate (x: x > 0) bend.identity).get 5;
      expected = bend.right 5;
    };

    validate."test-get-pred-fail-returns-left-same-value" = {
      expr = (bend.validate (x: x > 0) bend.identity).get (-1);
      expected = bend.left (-1);
    };

    int."test-get-integer-returns-right" = {
      expr = bend.int.get 42;
      expected = bend.right 42;
    };

    int."test-get-string-returns-left-string" = {
      expr = bend.int.get "hello";
      expected = bend.left "hello";
    };

    int."test-get-bool-returns-left-bool" = {
      expr = bend.int.get true;
      expected = bend.left true;
    };

    str."test-get-string-returns-right" = {
      expr = bend.str.get "hello";
      expected = bend.right "hello";
    };

    str."test-get-integer-returns-left-integer" = {
      expr = bend.str.get 42;
      expected = bend.left 42;
    };

    bool."test-get-bool-returns-right" = {
      expr = bend.bool.get true;
      expected = bend.right true;
    };

    bool."test-get-integer-returns-left-integer" = {
      expr = bend.bool.get 1;
      expected = bend.left 1;
    };

    list."test-get-list-returns-right" = {
      expr = bend.list.get [
        1
        2
        3
      ];
      expected = bend.right [
        1
        2
        3
      ];
    };

    list."test-get-string-returns-left-string" = {
      expr = bend.list.get "hello";
      expected = bend.left "hello";
    };

    nonEmpty."test-get-empty-list-returns-left-empty-list" = {
      expr = bend.nonEmpty.get [ ];
      expected = bend.left [ ];
    };

    nonEmpty."test-get-singleton-returns-right-head-tail" = {
      expr = bend.nonEmpty.get [ 42 ];
      expected = bend.right {
        head = 42;
        tail = [ ];
      };
    };

    nonEmpty."test-get-multi-returns-right-head-tail" = {
      expr = bend.nonEmpty.get [
        1
        2
        3
      ];
      expected = bend.right {
        head = 1;
        tail = [
          2
          3
        ];
      };
    };

    nonEmpty."test-set-reconstructs-list-from-nonEmpty" = {
      expr = bend.nonEmpty.set [ ] {
        head = 9;
        tail = [
          8
          7
        ];
      };
      expected = [
        9
        8
        7
      ];
    };

    withDefault."test-get-right-passes-through" = {
      expr = (bend.withDefault 0 bend.int).get 42;
      expected = bend.right 42;
    };

    withDefault."test-get-left-replaced-by-default" = {
      expr = (bend.withDefault 0 bend.int).get "bad";
      expected = bend.right 0;
    };

    withDefault."test-set-unaffected" = {
      expr = (bend.withDefault 0 (bend.attr "n")).set { n = 1; } 99;
      expected = {
        n = 99;
      };
    };

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
            (bend.validate (s: s != "") bend.identity)
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
            (bend.validate (s: s != "") bend.identity)
          ];
        in
        lens.get { name = ""; };
      expected = bend.left "";
    };

    integration."test-integration-swap-works-on-int-failure-path" = {
      expr = bend.swap (bend.int.get "hello");
      expected = bend.right "hello";
    };

    integration."test-integration-withDefault-absorbs-failure-in-pipe" = {
      expr =
        let
          lens = bend.pipe [
            (bend.attr "count")
            (bend.withDefault 0 bend.int)
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
      expected = {
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
      expected = {
        items = [
          1
          2
          3
        ];
      };
    };

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
          lens = bend.compose (bend.apply ({ x, y }: x + y)) (bend.validate (n: n > 20) bend.identity);
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
          lens = bend.compose (bend.apply ({ x, y }: x + y)) (bend.validate (n: n > 30) bend.identity);
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

    sequence."test-sequence-extracts-three-attributes-as-list" = {
      expr =
        let
          lens = bend.sequence [
            (bend.attr "x")
            (bend.attr "y")
            (bend.attr "z")
          ];
        in
        lens.get {
          x = 1;
          y = 2;
          z = 3;
        };
      expected = bend.right [
        1
        2
        3
      ];
    };

    sequence."test-sequence-missing-attribute-returns-left" = {
      expr =
        let
          lens = bend.sequence [
            (bend.attr "x")
            (bend.attr "y")
            (bend.attr "z")
          ];
        in
        lens.get {
          x = 1;
          y = 2;
        };
      expected = bend.left {
        x = 1;
        y = 2;
      };
    };

    sequence."test-sequence-single-lens" = {
      expr =
        let
          lens = bend.sequence [ (bend.attr "name") ];
        in
        lens.get { name = "alice"; };
      expected = bend.right [ "alice" ];
    };

    sequence."test-sequence-empty-list" = {
      expr =
        let
          lens = bend.sequence [ ];
        in
        lens.get { x = 1; };
      expected = bend.right [ ];
    };

    collect."test-collect-extracts-fields-as-object" = {
      expr =
        let
          lens = bend.collect [
            "x"
            "y"
            "z"
          ];
        in
        lens.get {
          x = 1;
          y = 2;
          z = 3;
          extra = 999;
        };
      expected = bend.right {
        x = 1;
        y = 2;
        z = 3;
      };
    };

    collect."test-collect-missing-field-returns-left" = {
      expr =
        let
          lens = bend.collect [
            "x"
            "y"
            "z"
          ];
        in
        lens.get {
          x = 1;
          y = 2;
        };
      expected = bend.left {
        x = 1;
        y = 2;
      };
    };

    collect."test-collect-single-field" = {
      expr =
        let
          lens = bend.collect [ "name" ];
        in
        lens.get {
          name = "alice";
          age = 30;
        };
      expected = bend.right { name = "alice"; };
    };

    collect."test-collect-empty-fields" = {
      expr =
        let
          lens = bend.collect [ ];
        in
        lens.get { x = 1; };
      expected = bend.right { };
    };

    transform."test-transform-validates-all-fields" = {
      expr =
        let
          lens = bend.transform {
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

    transform."test-transform-fails-on-first-invalid-field" = {
      expr =
        let
          lens = bend.transform {
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

    transform."test-transform-fails-on-middle-field" = {
      expr =
        let
          lens = bend.transform {
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

    transform."test-transform-single-field" = {
      expr =
        let
          lens = bend.transform { x = bend.int; };
        in
        lens.get {
          x = 42;
          extra = "ignored";
        };
      expected = bend.right { x = 42; };
    };

    transform."test-transform-with-custom-validator" = {
      expr =
        let
          lens = bend.transform {
            x = bend.int;
            y = bend.validate (s: builtins.stringLength s > 3) bend.str;
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

    transform."test-transform-custom-validator-fails" = {
      expr =
        let
          lens = bend.transform {
            x = bend.int;
            y = bend.validate (s: builtins.stringLength s > 3) bend.str;
          };
        in
        lens.get {
          x = 5;
          y = "hi";
        };
      expected = bend.left "hi";
    };

    index."test-index-zero-gets-first-element" = {
      expr =
        let
          lens = bend.index 0;
        in
        lens.get [
          10
          20
          30
        ];
      expected = bend.right 10;
    };

    index."test-index-two-gets-third-element" = {
      expr =
        let
          lens = bend.index 2;
        in
        lens.get [
          10
          20
          30
        ];
      expected = bend.right 30;
    };

    index."test-index-out-of-bounds-returns-left" = {
      expr =
        let
          lens = bend.index 5;
        in
        lens.get [
          10
          20
          30
        ];
      expected = bend.left [
        10
        20
        30
      ];
    };

    index."test-index-negative-returns-left" = {
      expr =
        let
          lens = bend.index (-1);
        in
        lens.get [
          10
          20
          30
        ];
      expected = bend.left [
        10
        20
        30
      ];
    };

    mapValues."test-mapValues-validates-all-object-values" = {
      expr =
        let
          lens = bend.mapValues bend.int;
        in
        lens.get {
          x = 1;
          y = 2;
          z = 3;
        };
      expected = bend.right {
        x = 1;
        y = 2;
        z = 3;
      };
    };

    mapValues."test-mapValues-fails-on-invalid-value" = {
      expr =
        let
          lens = bend.mapValues bend.int;
        in
        lens.get {
          x = 1;
          y = "bad";
          z = 3;
        };
      expected = bend.left "bad";
    };

    mapValues."test-mapValues-transforms-values" = {
      expr =
        let
          lens = bend.mapValues (bend.map (x: x * 2) bend.identity);
        in
        lens.get {
          a = 1;
          b = 2;
          c = 3;
        };
      expected = bend.right {
        a = 2;
        b = 4;
        c = 6;
      };
    };

    mapValues."test-mapValues-empty-object" = {
      expr =
        let
          lens = bend.mapValues bend.int;
        in
        lens.get { };
      expected = bend.right { };
    };

    functor."test-bend-as-function-calls-apply" = {
      expr = bend ({ x, y }: x + y) {
        x = 10;
        y = 32;
      };
      expected = bend.right 42;
    };

    functor."test-bend-functor-with-three-args" = {
      expr =
        bend
          (
            {
              a,
              b,
              c,
            }:
            a + b + c
          )
          {
            a = 1;
            b = 2;
            c = 3;
          };
      expected = bend.right 6;
    };

    functor."test-bend-functor-missing-arg-returns-left" = {
      expr = bend ({ x, y }: x + y) { x = 10; };
      expected = bend.left { x = 10; };
    };

    functor."test-bend-chained-two-levels" = {
      expr = bend ({ x }: x) ({ y }: y) {
        x = {
          y = 22;
        };
      };
      expected = bend.right 22;
    };

    functor."test-bend-chained-three-levels" = {
      expr = bend ({ a }: a) ({ b }: b) ({ c }: c) {
        a = {
          b = {
            c = 99;
          };
        };
      };
      expected = bend.right 99;
    };

    functor."test-bend-chained-missing-inner-key-returns-left" = {
      expr = bend ({ x }: x) ({ y }: y) {
        x = {
          z = 22;
        };
      };
      expected = bend.left { z = 22; };
    };

    functor."test-bend-chained-missing-outer-key-returns-left" = {
      expr = bend ({ x }: x) ({ y }: y) { z = 1; };
      expected = bend.left { z = 1; };
    };

    functor."test-bend-chained-with-extra-keys-ignored" = {
      expr = bend ({ x }: x) ({ y }: y) {
        x = {
          y = 5;
          extra = 99;
        };
      };
      expected = bend.right 5;
    };

    bifunctor."test-bimap-maps-right" = {
      expr = (bend.bimap (_: "err") (x: x * 2) bend.int).get 5;
      expected = bend.right 10;
    };

    bifunctor."test-bimap-maps-left" = {
      expr = (bend.bimap (_: "err") (x: x * 2) bend.int).get "bad";
      expected = bend.left "err";
    };

    bifunctor."test-lmap-maps-left-only" = {
      expr = (bend.lmap (_: "replaced") bend.int).get "bad";
      expected = bend.left "replaced";
    };

    bifunctor."test-lmap-passes-right-unchanged" = {
      expr = (bend.lmap (_: "replaced") bend.int).get 42;
      expected = bend.right 42;
    };

    bifunctor."test-rmap-maps-right-only" = {
      expr = (bend.rmap (x: x + 1) bend.int).get 5;
      expected = bend.right 6;
    };

    bifunctor."test-rmap-passes-left-unchanged" = {
      expr = (bend.rmap (x: x + 1) bend.int).get "bad";
      expected = bend.left "bad";
    };

    bifunctor."test-bimap-set-delegates-to-inner" = {
      expr = (bend.bimap (_: "err") (x: x) (bend.attr "x")).set { x = 1; y = 2; } 99;
      expected = { x = 99; y = 2; };
    };

    errors."test-label-replaces-left" = {
      expr = (bend.label "bad input" bend.int).get "x";
      expected = bend.left "bad input";
    };

    errors."test-label-passes-right" = {
      expr = (bend.label "bad input" bend.int).get 5;
      expected = bend.right 5;
    };

    errors."test-labelWith-applies-fn-to-left" = {
      expr = (bend.labelWith (v: "got: ${builtins.typeOf v}") bend.str).get 42;
      expected = bend.left "got: int";
    };

    errors."test-region-wraps-left-with-context" = {
      expr = (bend.region "parsing config" bend.int).get "x";
      expected = bend.left { context = "parsing config"; inner = "x"; };
    };

    errors."test-region-passes-right" = {
      expr = (bend.region "parsing config" bend.int).get 5;
      expected = bend.right 5;
    };

    errors."test-region-stacks" = {
      expr = (bend.region "outer" (bend.region "inner" bend.int)).get "x";
      expected = bend.left { context = "outer"; inner = { context = "inner"; inner = "x"; }; };
    };

    errors."test-annotate-wraps-left-with-path-and-got" = {
      expr = (bend.annotate ["user" "name"] bend.str).get 42;
      expected = bend.left { path = ["user" "name"]; got = 42; };
    };

    errors."test-annotate-passes-right" = {
      expr = (bend.annotate ["user" "name"] bend.str).get "alice";
      expected = bend.right "alice";
    };

    errors."test-annotateWith-custom-error-fn" = {
      expr = (bend.annotateWith (path: got: { at = path; value = got; }) ["x"] bend.int).get "bad";
      expected = bend.left { at = ["x"]; value = "bad"; };
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
      expr = bend.defaultPathError ["a" "b"] "bad";
      expected = { path = ["a" "b"]; got = "bad"; };
    };

    "pipe-named"."test-unnamed-steps-unchanged" = {
      expr = (bend.pipe [ bend.str ]).get 42;
      expected = bend.left 42;
    };

    "pipe-named"."test-named-step-annotates-left" = {
      expr = (bend.pipe [
        { name = "age"; lens = bend.int; }
      ]).get "bad";
      expected = bend.left { path = ["age"]; got = "bad"; };
    };

    "pipe-named"."test-named-step-passes-right" = {
      expr = (bend.pipe [
        { name = "age"; lens = bend.int; }
      ]).get 30;
      expected = bend.right 30;
    };

    "pipe-named"."test-path-accumulates-across-named-steps" = {
      expr = (bend.pipe [
        { name = "user"; lens = bend.attr "user"; }
        { name = "name"; lens = bend.attr "name"; }
        bend.str
      ]).get { user = { name = 42; }; };
      expected = bend.left 42;
    };

    "pipe-named"."test-named-step-outer-fail-correct-path" = {
      expr = (bend.pipe [
        { name = "user"; lens = bend.attr "user"; }
        { name = "name"; lens = bend.attr "name"; }
        bend.str
      ]).get { };
      expected = bend.left { path = ["user"]; got = { }; };
    };

    "pipe-named"."test-named-step-custom-errorFn" = {
      expr = (bend.pipe [
        { name = "x"; lens = bend.int; errorFn = path: got: "fail at ${builtins.concatStringsSep "." path}"; }
      ]).get "bad";
      expected = bend.left "fail at x";
    };

    "pipe-named"."test-mixed-named-unnamed-compose" = {
      expr = (bend.pipe [
        { name = "count"; lens = bend.attr "count"; }
        bend.int
        (bend.ensure (n: n > 0) "must be positive" bend.identity)
      ]).get { count = -1; };
      expected = bend.left "must be positive";
    };

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
      "test-oneOf-first-right-wins" = {
        expr = (bend.oneOf [ bend.str bend.int bend.bool ]).get 42;
        expected = bend.right 42;
      };
      "test-oneOf-left-when-all-fail" = {
        expr = (bend.oneOf [ bend.str bend.int ]).get true;
        expected = bend.left true;
      };
      "test-alt-set-through-winning-branch" = {
        expr = (bend.alt (bend.attr "x") (bend.attr "y")).set { x = 1; y = 2; } 99;
        expected = { x = 99; y = 2; };
      };
    };

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
      expr = (bend.validate (bend.andP (x: x > 0) (x: x < 100)) bend.identity).get 50;
      expected = bend.right 50;
    };
    predicate."test-andP-with-validate-fails" = {
      expr = (bend.validate (bend.andP (x: x > 0) (x: x < 100)) bend.identity).get 150;
      expected = bend.left 150;
    };
    predicate."test-orP-with-ensure" = {
      expr = (bend.ensure (bend.orP builtins.isString builtins.isInt) "must be string or int" bend.identity).get true;
      expected = bend.left "must be string or int";
    };

    debug."test-debug-transparent-right" = {
      expr = (bend.debug "myLabel" bend.int).get 5;
      expected = bend.right 5;
    };
    debug."test-debug-transparent-left" = {
      expr = (bend.debug "myLabel" bend.int).get "bad";
      expected = bend.left "bad";
    };
    debug."test-debug-transparent-set" = {
      expr = (bend.debug "myLabel" (bend.attr "x")).set { x = 1; } 99;
      expected = { x = 99; };
    };
  };
}
