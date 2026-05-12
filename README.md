# Bend

Composable, bidirectional data transformation for Nix. Every lens either refines its input (`right`) or returns the original unchanged (`left`).

Bend draws from Haskell profunctor optics, Scala's `Either`, and the `adapt` primitive from [denful/nfx](https://github.com/denful/nfx).

The core idea is [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/): a validator for non-empty lists that returns `true` is discarding the proof it just computed; instead if the function returns `left empty` or `right { head; tail; }`, the data structure *is* the proof.

## The primitive

Everything composes from a single combinator:

```nix
adapt lens cmap smap fmap
# lens  — inner lens
# cmap  — focus from outer data into inner (can fail -> left)
# smap  — write inner result back into outer (returns either)
# fmap  — refine focused value (can fail -> left)
```

Everything else is derived from it.

## Either

```nix
bend.right 42        # { right = 42; }
bend.left  "hello"   # { left  = "hello"; }

bend.mapR  (x: x + 1) (bend.right 5)          # { right = 6; }
bend.mapL  (x: x + 1) (bend.left  5)          # { left  = 6; }
bend.chain (x: bend.right (x * 2)) (bend.right 5)  # { right = 10; }
bend.swap  (bend.right 1)                      # { left  = 1; }
```

Both `left` and `right` hold structured data, the library provides combinators for tracking error paths or error messages.

## Composing lenses

```nix
let lens = bend.pipe [
  (bend.attr "name")
  bend.str
  (bend.validate (s: s != ""))
];
in
lens.get { name = "alice"; }   # right "alice"
lens.get { name = ""; }        # left ""
lens.get { name = 42; }        # left 42
lens.get { }                   # left { }
```

Each step either refines or short-circuits with the point of failure. `compose` threads two lenses directly; `pipe` composes a list left-to-right.

## Bidirectional

Lenses write back through the same path they read. `set` returns `right` on success or `left` if the path cannot be reached.

```nix
let lens = bend.pipe [
  (bend.attr "config")
  (bend.attr "timeout")
];
in
lens.get { config = { timeout = 30; }; }
# right 30

lens.set { config = { timeout = 30; retry = 3; }; extra = true; } 60
# right { config = { timeout = 60; retry = 3; }; extra = true; }
```

`attr` returns `left` on `set` when the key is absent — you cannot write through a path that does not exist.

```nix
(bend.path ["a" "b"]).set { a = { b = 0; c = 1; }; } 99
# right { a = { b = 99; c = 1; }; }

(bend.path ["a" "b"]).set { } 99
# left { }
```

## Callability

`bend` is callable. Each function argument composes another `apply` lens. A non-function argument triggers `get`:

```nix
bend ({ x, y }: x + y) { x = 10; y = 32; }
# right 42

bend ({ x, y }: x + y) { x = 10; }
# left { x = 10; }   <- missing y, original attrset returned

bend ({ x }: x) ({ y }: y * 2) { x = { y = 22; }; }
# right 44
```

`apply` introspects argument names and extracts exactly those keys. Extra keys are ignored; missing keys short-circuit.

## Schema validation

`transform` validates each field with its own lens and short-circuits on the first failure:

```nix
(bend.transform {
  name = bend.str;
  age  = bend.int;
}).get { name = "alice"; age = 30; extra = true; }
# right { name = "alice"; age = 30; }

(bend.transform {
  name = bend.str;
  age  = bend.int;
}).get { name = "alice"; age = "thirty"; }
# left "thirty"
```

`transformAll` collects every failure instead of stopping at the first:

```nix
(bend.transformAll {
  name = bend.str;
  age  = bend.int;
}).get { name = 1; age = "thirty"; }
# left [
#   { field = "age";  got = "thirty"; }
#   { field = "name"; got = 1; }
# ]
```

Custom error shape per field:

```nix
(bend.transformAllWith (field: got: "${field}: expected ${builtins.typeOf got}") {
  name = bend.str;
  age  = bend.int;
}).get { name = 1; age = "thirty"; }
# left [ "age: expected string" "name: expected int" ]
```

## Error shaping

By default `left` carries the original bad value. These combinators give failures structure.

```nix
# Replace left with a fixed message
(bend.label "expected integer" bend.int).get "hello"
# left "expected integer"

# Machine-readable location
(bend.annotate ["user" "age"] bend.int).get "thirty"
# left { path = ["user" "age"]; got = "thirty"; }

# Stack outer context around inner error
(bend.region "server config"
  (bend.annotate ["port"] bend.int)).get "8080"
# left { context = "server config"; inner = { path = ["port"]; got = "8080"; } }

# Validate and label in one step
(bend.ensure (s: s != "") "name cannot be empty" bend.str).get ""
# left "name cannot be empty"
```

Named pipe steps track the path automatically when a step fails:

```nix
(bend.pipe [
  { name = "database"; lens = bend.attr "database"; }
  { name = "host";     lens = bend.attr "host"; }
  bend.str
]).get { database = { host = 5432; }; }
# left { path = ["database" "host"]; got = 5432; }
```

## Recovery and union types

`withDefault` replaces a left with a fixed value. `recover` receives the failed value and can attempt new logic:

```nix
let port = bend.recover
  (v: if builtins.isString v
      then let n = builtins.fromJSON v;
           in if builtins.isInt n then bend.right n else bend.left v
      else bend.left v)
  bend.int;
in
port.get 8080    # right 8080
port.get "8080"  # right 8080
port.get "http"  # left "http"
```

`alt` tries a second lens when the first fails. `oneOf` generalises to a list:

```nix
(bend.alt bend.str bend.int).get "hello"   # right "hello"
(bend.alt bend.str bend.int).get 42        # right 42
(bend.alt bend.str bend.int).get true      # left true

bend.oneOf [ bend.str bend.int bend.bool ]
```

Predicate combinators for `validate` and `ensure`:

```nix
let validPort = bend.andP (x: x > 0) (x: x < 65536);
in (bend.ensure validPort "invalid port" bend.int).get 80    # right 80
   (bend.ensure validPort "invalid port" bend.int).get 99999 # left "invalid port"
```

## Reference

**Primitives**

| Lens        | right when              | left when          |
|-------------|-------------------------|--------------------|
| `identity`  | always                  | never              |
| `attr "k"`  | key present             | key missing        |
| `path [ks]` | all keys present        | any key missing    |
| `int`       | value is integer        | not integer        |
| `str`       | value is string         | not string         |
| `bool`      | value is bool           | not bool           |
| `list`      | value is list           | not list           |
| `nonEmpty`  | list non-empty          | empty list         |
| `index n`   | n in bounds             | out of bounds      |

**Combinators**

| Combinator                 | Effect                                     |
|----------------------------|--------------------------------------------|
| `compose outer inner`      | thread inner through outer                 |
| `pipe [l ...]`             | compose left-to-right                      |
| `focus getF setF`          | lift pure get/set into a lens              |
| `parse fmap lens`          | apply fmap to focused value                |
| `map f lens`               | transform focused value with pure function |
| `validate pred`            | left when pred fails, focuses raw value    |
| `validateWith pred lens`   | left when pred fails, with custom lens     |
| `withDefault d lens`       | replace left with `right d`                |
| `recover f lens`           | call f on left to attempt recovery         |
| `alt lensA lensB`          | try lensA, fall back to lensB              |
| `oneOf [l ...]`            | try each lens in order                     |
| `apply fn`                 | extract fn args from input attrset         |
| `sequence [l ...]`         | collect lens results into a list           |
| `collect [k ...]`          | extract named fields into attrset          |
| `transform {k = l; ...}`   | validate each field, short-circuit         |
| `transformAll {k = l; ...}`| validate each field, collect all failures  |
| `mapValues lens`           | apply lens to every value in attrset       |
| `bimap fL fR lens`         | map both branches                          |
| `lmap f lens`              | map left branch only                       |
| `rmap f lens`              | map right branch only                      |
| `label msg lens`           | replace left with fixed message            |
| `annotate path lens`       | wrap left with `{ path; got }`             |
| `region ctx lens`          | wrap left with `{ context; inner }`        |
| `ensure pred msg lens`     | validate and label in one step             |
| `debug label lens`         | trace values to stderr, transparent        |
