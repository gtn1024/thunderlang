package thunderlang.ast

import std.unittest.*
import std.unittest.testmacro.*
import thunderlang.token.*

@Test
func testString() {
    let program = Program([
        LetStatement(
            Token(TokenType.LET, "let"),
            Identifier(Token(TokenType.IDENT, "myVar"), "myVar"),
            Identifier(Token(TokenType.IDENT, "anotherVar"), "anotherVar")
        )
    ])

    @Expect(program.string(), "let myVar = anotherVar;")
}
