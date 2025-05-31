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
    testIdentifier(expr, "foobar")
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
    testLiteralExpression(expr, 5)
}

@Test
func testParsingPrefixExpressions() {
    let prefixTests: Array<(String, String, Any)> = [
        ("!5;", "!", 5),
        ("-15;", "-", 15),
        ("!true;", "!", true),
        ("!false;", "!", false)
    ]

    for ((input, `operator`, value) in prefixTests) {
        let lexer = Lexer.create(input)
        let parser = Parser.create(lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        @Expect(program.statements.size, 1)

        let exprStmt = (program.statements[0] as ExpressionStatement).getOrThrow {=> IllegalStateException("program.statements[0] is not ExpressionStatement")}
        let expr = exprStmt.expression.getOrThrow {=> IllegalStateException("exprStmt.expression is None")}
        testPrefixExpression(expr, `operator`, value)
    }
}

func testIntegerLiteral(il: Expression, value: Int64): Bool {
    let integ = (il as IntegerLiteral).getOrThrow {=> IllegalStateException("il is not IntegerLiteral")}
    @Expect(integ.value, value)
    @Expect(integ.tokenLiteral(), value.toString())
    true
}

@Test
func testParsingInfixExpressions() {
    let infixTests: Array<(String, Any, String, Any)> = [
        ("5 + 5;", 5, "+", 5),
        ("5 - 5;", 5, "-", 5),
        ("5 * 5;", 5, "*", 5),
        ("5 / 5;", 5, "/", 5),
        ("5 > 5;", 5, ">", 5),
        ("5 < 5;", 5, "<", 5),
        ("5 == 5;", 5, "==", 5),
        ("5 != 5;", 5, "!=", 5),
        ("true == true", true, "==", true),
        ("true != false", true, "!=", false),
        ("false == false", false, "==", false)
    ]

    for ((input, leftValue, `operator`, rightValue) in infixTests) {
        let lexer = Lexer.create(input)
        let parser = Parser.create(lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        @Expect(program.statements.size, 1)

        let exprStmt = (program.statements[0] as ExpressionStatement).getOrThrow {=> IllegalStateException("program.statements[0] is not ExpressionStatement")}
        let expr = exprStmt.expression.getOrThrow {=> IllegalStateException("exprStmt.expression is None")}
        testInfixExpression(expr, leftValue, `operator`, rightValue)
    }
}

@Test
func testOperatorPrecedenceParsing() {
    let tests = [
        ("true", "true"),
        ("false", "false"),
        ("3 > 5 == false", "((3 > 5) == false)"),
        ("3 < 5 == true", "((3 < 5) == true)"),
        ("-a * b", "((-a) * b)"),
        ("!-a", "(!(-a))"),
        ("a + b + c", "((a + b) + c)"),
        ("a + b - c", "((a + b) - c)"),
        ("a * b * c", "((a * b) * c)"),
        ("a * b / c", "((a * b) / c)"),
        ("a + b / c", "(a + (b / c))"),
        ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
        ("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"),
        ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
        ("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
        ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
        ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
        ("(5 + 5) * 2", "((5 + 5) * 2)"),
        ("2 / (5 + 5)", "(2 / (5 + 5))"),
        ("-(5 + 5)", "(-(5 + 5))"),
        ("!(true == true)", "(!(true == true))")
    ]

    for ((input, expected) in tests) {
        let lexer = Lexer.create(input)
        let parser = Parser.create(lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        let actual = program.string()
        @Expect(actual, expected)
    }
}

func testLiteralExpression(expression: Expression, expected: Any): Bool {
    match (expected) {
        case i: Int64 => return testIntegerLiteral(expression, i)
        case s: String => return testIdentifier(expression, s)
        case b: Bool => return testBooleanLiteral(expression, b)
        case _ => throw IllegalStateException("expression is not IntegerLiteral")
    }
    true
}

func testIdentifier(expression: Expression, value: String): Bool {
    let ident = (expression as Identifier).getOrThrow {=> IllegalStateException("expression is not Identifier")}
    @Expect(ident.value, value)
    @Expect(ident.tokenLiteral(), value)
    true
}

func testBooleanLiteral(expression: Expression, value: Bool): Bool {
    let bo = (expression as Boolean).getOrThrow {=> IllegalStateException("expression is not BooleanLiteral")}
    @Expect(bo.value, value)
    @Expect(bo.tokenLiteral(), value.toString())
    true
}

func testPrefixExpression(expression: Expression, `operator`: String, value: Any): Bool {
    let opExp = (expression as PrefixExpression).getOrThrow {=> IllegalStateException("expression is not PrefixExpression")}
    @Expect(opExp.`operator`, `operator`)
    testLiteralExpression(opExp.right, value)
    true
}

func testInfixExpression(expression: Expression, leftValue: Any, `operator`: String, rightValue: Any): Bool {
    let infixExp = (expression as InfixExpression).getOrThrow {=> IllegalStateException("expression is not InfixExpression")}
    testLiteralExpression(infixExp.left, leftValue)
    @Expect(infixExp.`operator`, `operator`)
    testLiteralExpression(infixExp.right, rightValue)
    true
}

func testBooleanExpression() {
    let booleanTests = [
        ("true;", true),
        ("false;", false)
    ]

    for ((input, expected) in booleanTests) {
        let lexer = Lexer.create(input)
        let parser = Parser.create(lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        @Expect(program.statements.size, 1)

        let exprStmt = (program.statements[0] as ExpressionStatement).getOrThrow {=> IllegalStateException("program.statements[0] is not ExpressionStatement")}
        let expr = exprStmt.expression.getOrThrow {=> IllegalStateException("exprStmt.expression is None")}
        testBooleanLiteral(expr, expected)
    }
}
