{
  right = value: { right = value; };
  left = value: { left = value; };
  swap = e: if e ? right then { left = e.right; } else { right = e.left; };
  chain = f: e: if e ? right then f e.right else e;
  mapR = f: e: if e ? right then { right = f e.right; } else e;
  mapL = f: e: if e ? left then { left = f e.left; } else e;
}
