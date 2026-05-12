let
  bend = import ./.;
in
{
  nix-unit =
    (import ./tests/either.nix bend)
    // (import ./tests/adapt.nix bend)
    // (import ./tests/pipe.nix bend)
    // (import ./tests/core.nix bend)
    // (import ./tests/types.nix bend)
    // (import ./tests/integration.nix bend)
    // (import ./tests/apply.nix bend)
    // (import ./tests/sequence.nix bend)
    // (import ./tests/transform.nix bend)
    // (import ./tests/index.nix bend)
    // (import ./tests/combinators.nix bend)
    // (import ./tests/functor.nix bend)
    // (import ./tests/errors.nix bend)
    // (import ./tests/recovery.nix bend)
    // (import ./tests/predicate.nix bend)
    // (import ./tests/higher-order.nix bend)
    // (import ./tests/extras.nix bend)
    // (import ./tests/debug.nix bend);
}
