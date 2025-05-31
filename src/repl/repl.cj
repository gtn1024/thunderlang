package thunderlang.repl

import std.env.{ConsoleWriter, ConsoleReader}
import thunderlang.lexer.Lexer
import thunderlang.parser.Parser
import thunderlang.token.{Token, TokenType}

const PROMPT = ">> "

public func start(reader: ConsoleReader, writer: ConsoleWriter) {
    while (true) {
        writer.write(PROMPT)
        writer.flush()
        let line = reader.readln() ?? return
        let l = Lexer.create(line)

        let p = Parser.create(l)

        let program = p.parseProgram()
        if (p.getErrors().size != 0) {
            printParserErrors(writer, p.getErrors())
            continue
        }
        writer.writeln(program.string())
        writer.flush()
    }
}

func printParserErrors(out: ConsoleWriter, errors: Array<String>) {
    out.write("|  Errors:\n")
    for (error in errors) {
        out.write("|  ${error}\n")
    }
}
