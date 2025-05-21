package thunderlang.token

public enum TokenType {
    | ILLEGAL
    | EOF

    // 标识符+字面量
    | IDENT
    | INT

    // 运算符
    | ASSIGN // =
    | PLUS // +

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
}

public struct Token {
    public Token(
        private let `type`: TokenType,
        private let literal: String
    ) {
    }
}
