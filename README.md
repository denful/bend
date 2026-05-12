<p align="right">
  <a href="https://dendritic.oeiuwq.com/sponsor"><img src="https://img.shields.io/badge/sponsor-vic-white?logo=githubsponsors&logoColor=white&labelColor=%23FF0000" alt="Sponsor Vic"/></a>
  <a href="https://deepwiki.com/denful/bend"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
  <a href="https://github.com/denful/den/releases"><img src="https://img.shields.io/github/v/release/denful/bend?style=plastic&logo=github&color=purple"/></a>
  <a href="https://dendritic.oeiuwq.com"><img src="https://img.shields.io/badge/Dendritic-Nix-informational?logo=nixos&logoColor=white" alt="Dendritic Nix"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/denful/bend" alt="License"/></a>
  <a href="https://github.com/denful/bend/actions"><img src="https://github.com/denful/bend/actions/workflows/test.yml/badge.svg" alt="CI Status"/></a>
</p>

> bend and [vic](https://bsky.app/profile/oeiuwq.bsky.social)'s [dendritic libs](https://dendritic.oeiuwq.com) made for you with Love++ and AI--. If you like my work, consider [sponsoring](https://dendritic.oeiuwq.com/sponsor)

# **Bend**. Lens based data parser-combinators. Bidirectional transformation and validation pipelines for Nix.

Bend draws from Haskell profunctor optics, Scala's `Either`, the `adapt` primitive from [denful/nfx](https://github.com/denful/nfx) and parser-combinators.

The core idea is [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/): a validator for non-empty lists that returns `true` is discarding the proof it just computed; instead if the function returns `left empty` or `right { head; tail; }`, the data structure *is* the proof.
Every lens either refines its input (`right`) or returns the original unchanged (`left`).


Bend’s combinator names deliberately match parser-combinator vocabulary:
This is not cosmetic. The names signal that [Bend is a parser combinator library](https://bend.denful.dev/explanation/validation-is-parsing), one that operates on Nix data structures instead of character streams, and that happens to also support bidirectional writes.

## **[Documentation at https://bend.denful.dev](https://bend.denful.dev)**

## Install

Bend has no dependencies

```nix
# flake.nix
inputs.bend.url = "github:denful/bend";
bend = inputs.bend.lib;
```

```nix
# default.nix
bend = import bend-sources.outPath;
```

## [zer0ver](https://0ver.org)

Bend uses 0-based versioning. `v0.x`

