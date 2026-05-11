# debug: transparent lens wrapper that traces intermediate get results
# Use to inspect pipeline values without changing behavior
# Output goes to stderr: "bend.debug [label]: <json>"
let
  debug =
    label: lens:
    {
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
