let
  debug = label: lens: {
    get =
      s:
      let
        r = lens.get s;
      in
      builtins.trace "bend.debug [${label}]: ${builtins.toJSON r}" r;
    set = lens.set;
  };
in
{
  inherit debug;
}
