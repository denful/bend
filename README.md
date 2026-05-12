<p align="right">
  <a href="https://dendritic.oeiuwq.com/sponsor"><img src="https://img.shields.io/badge/sponsor-vic-white?logo=githubsponsors&logoColor=white&labelColor=%23FF0000" alt="Sponsor Vic"/></a>
  <a href="https://deepwiki.com/denful/bend"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
  <a href="https://github.com/denful/den/releases"><img src="https://img.shields.io/github/v/release/denful/bend?style=plastic&logo=github&color=purple"/></a>
  <a href="https://dendritic.oeiuwq.com"><img src="https://img.shields.io/badge/Dendritic-Nix-informational?logo=nixos&logoColor=white" alt="Dendritic Nix"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/denful/bend" alt="License"/></a>
  <a href="https://github.com/denful/bend/actions"><img src="https://github.com/denful/bend/actions/workflows/test.yml/badge.svg" alt="CI Status"/></a>
</p>

> bend and [vic](https://bsky.app/profile/oeiuwq.bsky.social)'s [dendritic libs](https://dendritic.oeiuwq.com) made for you with Love++ and AI--. If you like my work, consider [sponsoring](https://dendritic.oeiuwq.com/sponsor)

# Bend

Composable, bidirectional data transformation for Nix. Every lens either refines its input (`right`) or returns the original unchanged (`left`).

Bend draws from Haskell profunctor optics, Scala's `Either`, and the `adapt` primitive from [denful/nfx](https://github.com/denful/nfx).

The core idea is [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/): a validator for non-empty lists that returns `true` is discarding the proof it just computed; instead if the function returns `left empty` or `right { head; tail; }`, the data structure *is* the proof.

## The [`adapt`](nix/adapt.nix) primitive

Everything composes from a single combinator:

```nix
adapt lens from back refine
# lens    — inner lens
# from    — extract inner source from outer
# back    — write inner result back into outer
# refine  — refine focused value
```

## [Either](nix/either.nix)

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

`transformAll` validates every field and returns per-field outcomes on failure:

```nix
(bend.transformAll {
  name = bend.str;
  age  = bend.int;
}).get { name = "alice"; age = "thirty"; }
# left {
#   name = right "alice";
#   age  = left { field = "age"; got = "thirty"; };
# }

(bend.transformAll {
  name = bend.str;
  age  = bend.int;
}).get { name = "alice"; age = 30; }
# right { name = "alice"; age = 30; }
```

Custom error shape per field:

```nix
(bend.transformAllWith (field: got: "${field}: expected ${builtins.typeOf got}") {
  name = bend.str;
  age  = bend.int;
}).get { name = "alice"; age = "thirty"; }
# left {
#   name = right "alice";
#   age  = left "age: expected string";
# }
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

## Modifying in place

`over` applies a function to the focused value and returns the updated whole — the third pillar alongside `get` and `set`:

```nix
bend.over (bend.path ["config" "timeout"]) (n: n * 2) { config = { timeout = 30; }; }
# right { config = { timeout = 60; }; }

bend.over bend.int (n: n + 1) "not-a-number"
# left "not-a-number"
```

`getOr` extracts the raw value without the Either wrapper, returning a default on left:

```nix
bend.getOr 0 bend.int 42      # 42
bend.getOr 0 bend.int "bad"   # 0
```

## Isomorphisms and prisms

`iso f g` is a lens that always succeeds in both directions. `get = right ∘ f`, `set` ignores the source and applies `g`:

```nix
let celsius = bend.iso (f: (f - 32.0) / 1.8) (c: c * 1.8 + 32.0);
in celsius.get 212.0   # right 100.0
   celsius.set 0 100.0 # right 212.0
```

`prism build match` focuses on one variant of a sum type. `match` returns `left s` for the wrong variant or `right a` for the focused value; `build` reconstructs:

```nix
let gitUrl = bend.prism
  (url: { type = "git"; inherit url; })
  (s: if s.type or "" == "git" then bend.right s.url else bend.left s);
in
gitUrl.get { type = "git"; url = "https://example.com"; }  # right "https://example.com"
gitUrl.get { type = "path"; path = "/foo"; }               # left { type = "path"; ... }
gitUrl.set { } "https://new.url"                           # right { type = "git"; url = "https://new.url"; }
```

## Traversals

`mapList` applies a lens to every list element and short-circuits on the first failure:

```nix
(bend.mapList bend.int).get [ 1 2 3 ]    # right [ 1 2 3 ]
(bend.mapList bend.int).get [ 1 "x" 3 ]  # left "x"
```

`each` collects only successes, silently dropping failures:

```nix
(bend.each bend.int).get [ 1 "x" 3 ]    # right [ 1 3 ]
```

`zip` focuses two parts of the same source simultaneously:

```nix
(bend.zip (bend.attr "x") (bend.attr "y")).get { x = 1; y = 2; z = 3; }
# right { a = 1; b = 2; }

(bend.zip (bend.attr "x") (bend.attr "y")).set { x = 0; y = 0; z = 3; } { a = 10; b = 20; }
# right { x = 10; y = 20; z = 3; }
```

## Conditional application

`when pred lens` applies a lens only when the predicate passes on the source, otherwise returns `right s` unchanged:

```nix
let maybeValidate = bend.when (v: v != null) bend.str;
in
maybeValidate.get null    # right null   (skipped)
maybeValidate.get "hi"    # right "hi"
maybeValidate.get 42      # left 42
```

`unless pred lens` is the inverse — applies when the predicate fails.

## Nullable and blank

`nullable lens` short-circuits on `null`, letting it pass as `right null`. Non-null values go through the inner lens:

```nix
(bend.nullable bend.str).get null    # right null
(bend.nullable bend.str).get "hi"    # right "hi"
(bend.nullable bend.str).get 42      # left 42
```

`nonBlank` accepts non-empty strings only. `attrOr "k" def` reads a key with a fallback default:

```nix
bend.nonBlank.get ""            # left ""
bend.nonBlank.get "hello"       # right "hello"

(bend.attrOr "port" 8080).get { }          # right 8080
(bend.attrOr "port" 8080).get { port = 3000; }  # right 3000
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

| Lens           | right when              | left when          |
|----------------|-------------------------|--------------------|
| `identity`     | always                  | never              |
| `attr "k"`     | key present             | key missing        |
| `attrOr "k" d` | always (`d` if missing) | never              |
| `path [ks]`    | all keys present        | any key missing    |
| `int`          | value is integer        | not integer        |
| `float`        | value is float          | not float          |
| `number`       | value is int or float   | neither            |
| `str`          | value is string         | not string         |
| `nonBlank`     | non-empty string        | empty or non-string|
| `bool`         | value is bool           | not bool           |
| `list`         | value is list           | not list           |
| `nonEmpty`     | list non-empty          | empty list         |
| `index n`      | n in bounds             | out of bounds      |

**Combinators**

| Combinator                  | Effect                                              |
|-----------------------------|-----------------------------------------------------|
| `compose outer inner`       | thread inner through outer                          |
| `pipe [l ...]`              | compose left-to-right                               |
| `focus getF setF`           | lift pure get/set into a lens                       |
| `iso f g`                   | isomorphism: `get = right ∘ f`, set ignores source  |
| `prism build match`         | sum-type focus: match extracts, build reconstructs  |
| `parse refine lens`         | apply refine to focused value                       |
| `map f lens`                | transform focused value with pure function          |
| `over lens f s`             | modify focused value in-place, return updated whole |
| `getOr def lens s`          | extract raw value or return `def` on left           |
| `validate pred`             | left when pred fails, focuses raw value             |
| `validateWith pred lens`    | left when pred fails, with custom lens              |
| `nullable lens`             | pass `null` through as `right null`, else apply lens|
| `withDefault d lens`        | replace left with `right d`                         |
| `when pred lens`            | apply lens only when pred passes on source          |
| `unless pred lens`          | apply lens only when pred fails on source           |
| `recover f lens`            | call f on left to attempt recovery                  |
| `alt lensA lensB`           | try lensA, fall back to lensB                       |
| `oneOf [l ...]`             | try each lens in order                              |
| `apply fn`                  | extract fn args from input attrset                  |
| `sequence [l ...]`          | collect lens results into a list                    |
| `collect [k ...]`           | extract named fields into attrset                   |
| `zip lensA lensB`           | focus two parts of same source into `{ a; b }`      |
| `transform {k = l; ...}`    | validate each field, short-circuit                  |
| `transformAll {k = l; ...}` | validate each field, collect all failures           |
| `mapValues lens`            | apply lens to every value in attrset                |
| `mapList lens`              | apply lens to every list element, short-circuit     |
| `each lens`                 | apply lens to every list element, collect successes |
| `mapKeys f`                 | rename attrset keys with f                          |
| `bimap fL fR lens`          | map both branches                                   |
| `lmap f lens`               | map left branch only                                |
| `rmap f lens`               | map right branch only                               |
| `label msg lens`            | replace left with fixed message                     |
| `annotate path lens`        | wrap left with `{ path; got }`                      |
| `region ctx lens`           | wrap left with `{ context; inner }`                 |
| `ensure pred msg lens`      | validate and label in one step                      |
| `debug label lens`          | trace values to stderr, transparent                 |
