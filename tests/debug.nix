bend: {
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
    expected = bend.right {
      x = 99;
    };
  };
}
