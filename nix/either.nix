{
  # Wrap a value on the right branch (success path)
  right = value: { right = value; };

  # Wrap a value on the left branch (failure path)
  left = value: { left = value; };

  # Invert an Either: right ↔ left
  swap = e: if e ? right then { left = e.right; } else { right = e.left; };

  # Monadic bind: apply function to right value, pass left unchanged
  chain = f: e: if e ? right then f e.right else e;

  # Map over right branch, pass left unchanged
  mapR = f: e: if e ? right then { right = f e.right; } else e;

  # Map over left branch, pass right unchanged
  mapL = f: e: if e ? left then { left = f e.left; } else e;
}
