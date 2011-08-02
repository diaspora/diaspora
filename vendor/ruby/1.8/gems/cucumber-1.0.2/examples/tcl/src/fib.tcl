proc fib {n} {
    return [expr {$n<2 ? $n : [fib [expr $n-1]] + [fib [expr $n-2]]}]
}
