package thunderlang

import std.env.{getStdIn, getStdOut, getStdErr}
import thunderlang.repl.start

main(): Int64 {
    println("This is the Thunder Programming Language!")
    println("Feel free to type in commands!")
    start(getStdIn(), getStdOut())
    return 0
}
