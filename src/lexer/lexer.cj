package thunderlang.lexer

import thunderlang.token.{Token, TokenType}

public class Lexer {
    private var position: Int64 = 0
    private var readPosition: Int64 = 0
    private var ch: Rune = r'\0'

    public Lexer(
        private let runes: Array<Rune>
    ) {
    }

    public static func create(input: String): Lexer {
        let runes = input.toRuneArray()
        let lexer = Lexer(runes)
        lexer.readRune()
        lexer
    }

    public func readRune() {
        if (this.readPosition >= this.runes.size) {
            this.ch = r'\0'
        } else {
            this.ch = this.runes[this.readPosition]
        }
        this.position = this.readPosition
        this.readPosition++
    }

    public func nextToken() {
        let token = match (this.ch) {
            case r'=' => newToken(TokenType.ASSIGN, this.ch)
            case r';' => newToken(TokenType.SEMICOLON, this.ch)
            case r'(' => newToken(TokenType.LPAREN, this.ch)
            case r')' => newToken(TokenType.RPAREN, this.ch)
            case r'{' => newToken(TokenType.LBRACE, this.ch)
            case r'}' => newToken(TokenType.RBRACE, this.ch)
            case r',' => newToken(TokenType.COMMA, this.ch)
            case r'+' => newToken(TokenType.PLUS, this.ch)
            case r'\0' => Token(TokenType.EOF, "")
            case _ => throw IllegalArgumentException("Illegal character: ${this.ch}")
        }
        this.readRune()
        token
    }

    func newToken(tokenType: TokenType, ch: Rune): Token {
        Token(tokenType, String(ch))
    }
}
