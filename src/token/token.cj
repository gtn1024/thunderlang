package thunderlang.token

import std.deriving.Derive
import std.collection.HashMap

@Derive[ToString, Equatable, Hashable]
public enum TokenType {
    | ILLEGAL
    | EOF

    // 标识符+字面量
    | IDENT
    | INT

    // 运算符
    | ASSIGN // =
    | PLUS // +
    | MINUS // -
    | BANG // !
    | ASTERISK // *
    | SLASH // /

    | LT // <
    | GT // >
    | EQ // ==
    | NOT_EQ // !=

    // 分隔符
    | COMMA // ,
    | SEMICOLON // ;

    | LPAREN // (
    | RPAREN // )
    | LBRACE // {
    | RBRACE // }

    // 关键字
    | FUNCTION
    | LET
    | TRUE
    | FALSE
    | IF
    | ELSE
    | RETURN
}

@Derive[ToString, Equatable]
public struct Token {
    public Token(
        public let `type`: TokenType,
        public let literal: String
    ) {
    }
}

let keywords = HashMap([
    ("fn", TokenType.FUNCTION),
    ("let", TokenType.LET),
    ("true", TokenType.TRUE),
    ("false", TokenType.FALSE),
    ("if", TokenType.IF),
    ("else", TokenType.ELSE),
    ("return", TokenType.RETURN)
])

public func lookupIdent(ident: String): TokenType {
    if (let Some(token) <- keywords.get(ident)) {
        return token
    }
    TokenType.IDENT
}
