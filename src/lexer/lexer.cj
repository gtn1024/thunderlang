package thunderlang.lexer

import thunderlang.token.*

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
        this.skipWhitespace()

        let token = match (this.ch) {
            case r'=' => match (this.peekRune()) {
                case r'=' =>
                    let ch = this.ch
                    this.readRune()
                    let literal = String(ch) + String(this.ch)
                    Token(TokenType.EQ, literal)
                case _ => newToken(TokenType.ASSIGN, this.ch)
            }
            case r'+' => newToken(TokenType.PLUS, this.ch)
            case r'-' => newToken(TokenType.MINUS, this.ch)
            case r'!' => match (this.peekRune()) {
                case r'=' =>
                    let ch = this.ch
                    this.readRune()
                    let literal = String(ch) + String(this.ch)
                    Token(TokenType.NOT_EQ, literal)
                case _ => newToken(TokenType.BANG, this.ch)
            }
            case r'*' => newToken(TokenType.ASTERISK, this.ch)
            case r'/' => newToken(TokenType.SLASH, this.ch)
            case r'<' => newToken(TokenType.LT, this.ch)
            case r'>' => newToken(TokenType.GT, this.ch)
            case r';' => newToken(TokenType.SEMICOLON, this.ch)
            case r'(' => newToken(TokenType.LPAREN, this.ch)
            case r')' => newToken(TokenType.RPAREN, this.ch)
            case r'{' => newToken(TokenType.LBRACE, this.ch)
            case r'}' => newToken(TokenType.RBRACE, this.ch)
            case r',' => newToken(TokenType.COMMA, this.ch)
            case r'\0' => Token(TokenType.EOF, "")
            case _ => match {
                case this.isLetter(this.ch) =>
                    let literal = this.readIdentifier()
                    return Token(lookupIdent(literal), literal)
                case isDigit(this.ch) =>
                    let literal = this.readNumber()
                    return Token(TokenType.INT, literal)
                case _ => newToken(TokenType.ILLEGAL, this.ch)
            }
        }

        this.readRune()
        token
    }

    func peekRune(): Rune {
        if (this.readPosition >= this.runes.size) {
            return r'\0'
        } else {
            return this.runes[this.readPosition]
        }
    }

    func skipWhitespace() {
        while (this.ch == r' ' || this.ch == r'\t' || this.ch == r'\n' || this.ch == r'\r') {
            this.readRune()
        }
    }

    func readNumber(): String {
        let position = this.position
        while (this.isDigit(this.ch)) {
            this.readRune()
        }
        String(this.runes[position..this.position])
    }

    func readIdentifier(): String {
        let position = this.position
        while (this.isLetter(this.ch)) {
            this.readRune()
        }
        String(this.runes[position..this.position])
    }

    func isDigit(ch: Rune): Bool {
        ch >= r'0' && ch <= r'9'
    }

    func isLetter(ch: Rune): Bool {
        (ch >= r'a' && ch <= r'z') || (ch >= r'A' && ch <= r'Z') || ch == r'_'
    }

    func newToken(tokenType: TokenType, ch: Rune): Token {
        Token(tokenType, String(ch))
    }
}
