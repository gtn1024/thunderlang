package thunderlang.repl

import std.env.{ConsoleWriter, ConsoleReader}
import thunderlang.lexer.Lexer
import thunderlang.token.{Token, TokenType}

const PROMPT = ">> "

public func start(reader: ConsoleReader, writer: ConsoleWriter) {
    while (true) {
        writer.write(PROMPT)
        writer.flush()
        let line = reader.readln() ?? return
        let l = Lexer.create(line)

        while (true) {
            let token = l.nextToken()
            if (token.`type` == TokenType.EOF) {
                break
            }
            writer.writeln(token.toString())
        }
    }
}
