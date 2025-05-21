package thunderlang.lexer

import std.unittest.*
import std.unittest.testmacro.*
import thunderlang.token.*

@Test
func testNextToken() {
    let input = "=+(),;"

    let tests = [
        (TokenType.ASSIGN, "="),
        (TokenType.PLUS, "+"),
        (TokenType.LPAREN, "("),
        (TokenType.RPAREN, ")"),
        (TokenType.COMMA, ","),
        (TokenType.SEMICOLON, ";"),
        (TokenType.EOF, "")
    ]

    let lexer = Lexer.create(input)

    for ((expectedType, expectedLiteral) in tests) {
        let token = lexer.nextToken()
        @Expect(token.`type`, expectedType)
        @Expect(token.literal, expectedLiteral)
    }
}
