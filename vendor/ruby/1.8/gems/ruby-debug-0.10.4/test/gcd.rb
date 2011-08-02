#!/usr/bin/env ruby

# GCD. We assume positive numbers
def gcd(a, b)
  # Make: a <= b
  if a > b
    a, b = [b, a]
  end

  return nil if a <= 0

  if a == 1 or b-a == 0
    return a
  end
  return gcd(b-a, a)
end

gcd(3,5)
