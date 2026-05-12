help:
  just -l

docs:
  cd docs && pnpm run dev

fmt *args:
  treefmt {{args}}

ci:
  just fmt --ci --no-cache
  just test

test suite="all" *args:
  nix-unit --expr 'let x = import ./tests.nix; in if "{{suite}}" == "all" then x else x.{{suite}}' {{args}}
