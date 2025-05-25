package thunderlang.parser

import std.unittest.*
import std.unittest.testmacro.*
import thunderlang.token.{TokenType}
import thunderlang.lexer.Lexer
import thunderlang.ast.*

@Test
func testLetStatements() {
    let input = """
    let x = 5;
    let y = 10;
    let foobar = 838383;
    """

    let lexer = Lexer.create(input)
    let parser = Parser.create(lexer)

    let program = parser.parseProgram()
    checkParserErrors(parser)
    @Expect(program.statements.size, 3)

    let tests = [
        "x",
        "y",
        "foobar"
    ]
    for (i in 0..tests.size) {
        let tt = tests[i]
        let stmt = program.statements[i]
        @Expect(testLetStatement(stmt, tt), true)
    }
}

func testLetStatement(s: Statement, name: String): Bool {
    let letStmt = (s as LetStatement).getOrThrow {=> IllegalStateException("s is not LetStatement")}
    @Expect(letStmt.tokenLiteral(), "let")
    @Expect(letStmt.name.value, name)
    @Expect(letStmt.name.tokenLiteral(), name)

    true
}

func checkParserErrors(p: Parser) {
    let errors = p.getErrors()
    if (errors.size == 0) {
        return
    }

    println("parser has ${errors.size} errors:")
    for (error in errors) {
        println("parser error: ${error}")
    }
    @Expect(errors.size, 0)
}

@Test
func testReturnStatements() {
    let input = """
    return 5;
    return 10;
    return 993 322;
    """

    let lexer = Lexer.create(input)
    let parser = Parser.create(lexer)

    let program = parser.parseProgram()
    checkParserErrors(parser)

    @Expect(program.statements.size, 3)

    for (stmt in program.statements) {
        if (let Some(returnStmt) <- (stmt as ReturnStatement)) {
            @Expect(returnStmt.tokenLiteral(), "return")
        } else {
            throw IllegalStateException("stmt is not ReturnStatement")
        }
    }
}

@Test
func testIdentifierExpression() {
    let input = "foobar;"

    let lexer = Lexer.create(input)
    let parser = Parser.create(lexer)
    let program = parser.parseProgram()
    checkParserErrors(parser)

    @Expect(program.statements.size, 1)

    let exprStmt = (program.statements[0] as ExpressionStatement).getOrThrow {=> IllegalStateException("program.statements[0] is not ExpressionStatement")}
    let expr = exprStmt.expression.getOrThrow {=> IllegalStateException("exprStmt.expression is None")}
    let ident = (expr as Identifier).getOrThrow {=> IllegalStateException("exprStmt.expression is not Identifier")}
    @Expect(ident.value, "foobar")
    @Expect(ident.tokenLiteral(), "foobar")
}

@Test
func testIntegerLiteralExpression() {
    let input = "5;"

    let lexer = Lexer.create(input)
    let parser = Parser.create(lexer)
    let program = parser.parseProgram()
    checkParserErrors(parser)

    @Expect(program.statements.size, 1)

    let exprStmt = (program.statements[0] as ExpressionStatement).getOrThrow {=> IllegalStateException("program.statements[0] is not ExpressionStatement")}
    let expr = exprStmt.expression.getOrThrow {=> IllegalStateException("exprStmt.expression is None")}

    let intLit = (expr as IntegerLiteral).getOrThrow {=> IllegalStateException("exprStmt.expression is not IntegerLiteral")}
    @Expect(intLit.value, 5)
    @Expect(intLit.tokenLiteral(), "5")
}
