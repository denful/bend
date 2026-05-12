bend: {
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
}
