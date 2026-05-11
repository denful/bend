# Bend — Data Transformation and Validation pipelines

Composable, bidirectional data bending for Nix. Based on Scala's Either and Lenses.

## One primitive

Everything is based on [`adapt`](nix/adapt.nix):

> The `adapt` combinator comes from [denful/nfx](https://github.com/denful/nfx) kernel where it is the base for Lenses-based effects.


```nix
adapt lens cmap smap fmap
# lens  — inner lens
# cmap  — contravariant: focus from outer data into inner (can fail → left)
# smap  — write inner result back into outer (pure -- cannot fail)
# fmap  — covariant: refine focused value (can fail → left)
```

`compose`, `pipe`, `parse`, `focus`, `map`, `validate` — all [one-liners](nix/core.nix) over `adapt`.

## Core idea: [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)

When a function checks a list and returns `true/false` it throws away the proof it just computed. A function that checks a list and returns `{ head; tail; }` keeps the proof. The data structure *is* the proof.

Bend makes this the default. Every lens either refines data (`right`) or returns the original unchanged (`left`) -- An `Either` data structure. No booleans as validation results. Structured data instead of error strings.

```nix
# Minimal example, using the `bend.int` validator
int.get 42        # right 42
int.get "hello"   # left "hello"  ← original invalid value, not an error message
```

## Functor shorthand

`bend` is callable. Each function argument composes another `apply` lens. The first non-function argument triggers `get` on the accumulated lens:

```nix
bend ({ x, y }: x + y) { x = 10; y = 32; }
# right 42

bend ({ x, y }: x + y) { x = 10; }
# left { x = 10; }   ← missing y, original attrset returned
```

Chain functions to zoom into nested structures transparently:

```nix
bend ({ x }: x) ({ y }: y * 2) { x = { y = 22; }; }
# right 44   ← first fn refines x, second refines y from x's value

bend ({ a }: a) ({ b }: b) ({ c }: c) { a = { b = { c = 99; }; }; }
# right 99

bend ({ x }: x) ({ y }: y) { x = { z = 1; }; }
# left { z = 1; }   ← inner lens failed, point of failure returned
```

## apply — extract and call

`apply` introspects the function's argument names and extracts exactly those keys:

```nix
let lens = bend.apply ({ first, last }: "${first} ${last}");
in
lens.get { first = "Alice"; last = "Smith"; role = "admin"; }
# right "alice smith"   ← extra keys ignored

lens.get { first = "Alice"; }
# left { first = "Alice"; }   ← missing last, short-circuits
```

Compose `apply` with validators to parse-and-transform in one step:

```nix
let
  lens = bend.compose
    (bend.apply ({ x, y }: x + y))
    (bend.validate (n: n > 20) bend.identity);
in
lens.get { x = 15; y = 10; }
# right 25

lens.get { x = 5; y = 10; }
# left 15   ← sum failed validation, sum value returned
```

## Validation pipelines

Lenses compose left-to-right with `pipe`. Each step either refines or short-circuits:

```nix
let
  lens = bend.pipe [
    (bend.attr "name")       # zoom into "name" field
    bend.str                 # validate it's a string
    (bend.validate           # validate non-empty
      (s: s != "")
      bend.identity)
  ];
in
lens.get { name = "alice"; }   # right "alice"
lens.get { name = ""; }        # left ""          ← empty string
lens.get { name = 42; }        # left 42          ← not a string
lens.get { }                   # left { }         ← missing field
```

Schema validation with `transform` — validates each field independently:

```nix
let
  lens = bend.transform {
    name = bend.str;
    age  = bend.int;
    tags = bend.pipe [ bend.list (bend.validate (l: l != []) bend.identity) ];
  };
in
lens.get { name = "alice"; age = 30; tags = ["admin"]; }
# right { name = "alice"; age = 30; tags = ["admin"]; }

lens.get { name = "alice"; age = "thirty"; tags = []; }
# left "thirty"   ← first failing value, not field name
```

## Transformation lenses — zoom in and out

Lenses are bidirectional. `get` zooms in. `set` writes back through the same path:

```nix
let lens = bend.attr "x";
in
lens.get { x = 1; y = 2; }        # right 1
lens.set { x = 1; y = 2; } 99     # { x = 99; y = 2; }
```

`compose` and `pipe` carry the write-back path automatically:

```nix
let
  lens = bend.pipe [
    (bend.attr "config")
    (bend.attr "timeout")
  ];
in
lens.get { config = { timeout = 30; }; }
# right 30

lens.set { config = { timeout = 30; retry = 3; }; extra = true; } 60
# { config = { timeout = 60; retry = 3; }; extra = true; }
#   ↑ writes at timeout, preserves all siblings at every level
```

Zoom into a list element, update, zoom back out:

```nix
let
  lens = bend.compose
    (bend.attr "items")
    bend.nonEmpty;
in
lens.get { items = [1 2 3]; }
# right { head = 1; tail = [2 3]; }

lens.set { items = []; } { head = 9; tail = [8 7]; }
# { items = [9 8 7]; }
```

Nested path shorthand:

```nix
(bend.path ["a" "b" "c"]).get { a = { b = { c = 42; }; }; }
# right 42

(bend.path ["a" "b" "c"]).set { a = { b = { c = 0; d = 1; }; }; } 99
# { a = { b = { c = 99; d = 1; }; }; }
```

## collect and sequence

Extract a subset of fields as an attrset:

```nix
(bend.collect ["x" "y"]).get { x = 1; y = 2; z = 999; }
# right { x = 1; y = 2; }   ← z excluded
```

Extract multiple lenses into a list from the same input:

```nix
(bend.sequence [
  (bend.attr "x")
  (bend.attr "y")
]).get { x = 10; y = 20; z = 30; }
# right [10 20]
```

## withDefault — absorb failures

```nix
let
  lens = bend.pipe [
    (bend.attr "count")
    (bend.withDefault 0 bend.int)
  ];
in
lens.get { count = 42; }      # right 42
lens.get { count = "bad"; }   # right 0    ← default absorbed the left
```

## Primitives

| Lens        | `get` right when…              | `get` left when…          |
|-------------|-------------------------------|---------------------------|
| `identity`  | always                        | never                     |
| `attr "k"`  | key present                   | key missing               |
| `path [ks]` | all keys present              | any key missing           |
| `int`       | value is integer              | not integer               |
| `str`       | value is string               | not string                |
| `bool`      | value is bool                 | not bool                  |
| `list`      | value is list                 | not list                  |
| `nonEmpty`  | list non-empty → `{head;tail}`| empty list                |
| `index n`   | n in bounds                   | out of bounds             |

## Combinators

| Combinator                  | Effect                                      |
|-----------------------------|---------------------------------------------|
| `compose outer inner`       | thread inner through outer                  |
| `pipe [l1 l2 …]`            | compose left-to-right                       |
| `focus getF setF`           | lift pure get/set into lens                 |
| `parse fmap lens`           | apply fmap to focused value                 |
| `map f lens`                | transform focused value with pure function  |
| `validate pred lens`        | left when pred fails, right when passes     |
| `withDefault d lens`        | replace left with `right d`                 |
| `apply fn`                  | extract fn's args from input attrset        |
| `sequence [l1 l2 …]`        | collect results of lenses into list         |
| `collect [k1 k2 …]`         | extract named fields into attrset           |
| `transform {k = lens; …}`   | validate each field with its own lens       |
| `mapValues lens`            | apply lens to every value in attrset        |

## Symmetric Either

`right` holds refined value. `left` holds original unrefined value. No exceptions. No sentinels.

```nix
bend.right 42          # { right = 42; }
bend.left  "hello"     # { left = "hello"; }
bend.swap  (right 1)   # { left = 1; }
bend.mapR  (x: x+1) (right 5)   # { right = 6; }
bend.mapL  (x: x+1) (left 5)    # { left = 6; }
bend.chain (x: right (x*2)) (right 5)   # { right = 10; }
```

