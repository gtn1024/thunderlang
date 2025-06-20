package thunderlang.parser

import thunderlang.lexer.Lexer
import thunderlang.token.{Token, TokenType}
import thunderlang.ast.*
import std.collection.{ArrayList, HashMap}
import std.convert.Parsable
import iota4cj.macros.*

@iota[1](
    LOWEST
    EQUALS      // ==
    LESSGREATER // >, <
    SUM         // +
    PRODUCT     // *
    PREFIX      // -X , !X
    CALL        // myFunction(X)
)

type prefixParseFn = () -> ?Expression
type infixParseFn = (Expression) -> ?Expression

let precedences = HashMap([
    (TokenType.EQ, EQUALS),
    (TokenType.NOT_EQ, EQUALS),
    (TokenType.LT, LESSGREATER),
    (TokenType.GT, LESSGREATER),
    (TokenType.PLUS, SUM),
    (TokenType.MINUS, SUM),
    (TokenType.SLASH, PRODUCT),
    (TokenType.ASTERISK, PRODUCT)
])

public class Parser {
    private var curToken: Token = Token(TokenType.EOF, "")
    private var peekToken: Token = Token(TokenType.EOF, "")
    private let errors: ArrayList<String> = ArrayList()
    private let prefixParseFns = HashMap<TokenType, prefixParseFn>()
    private let infixParseFns = HashMap<TokenType, infixParseFn>()

    public Parser(
        private let lexer: Lexer
    ) {
        this.registerPrefix(TokenType.IDENT, this.parseIdentifier)
        this.registerPrefix(TokenType.INT, this.parseIntegerLiteral)

        this.registerPrefix(TokenType.BANG, this.parsePrefixExpression)
        this.registerPrefix(TokenType.MINUS, this.parsePrefixExpression)
        this.registerPrefix(TokenType.TRUE, this.parseBoolean)
        this.registerPrefix(TokenType.FALSE, this.parseBoolean)
        this.registerPrefix(TokenType.LPAREN, this.parseGroupedExpression)

        this.registerInfix(TokenType.PLUS, this.parseInfixExpression)
        this.registerInfix(TokenType.MINUS, this.parseInfixExpression)
        this.registerInfix(TokenType.SLASH, this.parseInfixExpression)
        this.registerInfix(TokenType.ASTERISK, this.parseInfixExpression)
        this.registerInfix(TokenType.EQ, this.parseInfixExpression)
        this.registerInfix(TokenType.NOT_EQ, this.parseInfixExpression)
        this.registerInfix(TokenType.LT, this.parseInfixExpression)
        this.registerInfix(TokenType.GT, this.parseInfixExpression)
    }

    private func peekPrecedence(): Int64 {
        if (let Some(precedence) <- precedences.get(this.peekToken.`type`)) {
            return precedence
        }
        LOWEST
    }

    private func curPrecedence(): Int64 {
        if (let Some(precedence) <- precedences.get(this.curToken.`type`)) {
            return precedence
        }
        LOWEST
    }

    public static func create(lexer: Lexer): Parser {
        let p = Parser(lexer)
        p.nextToken()
        p.nextToken()
        p
    }

    public func getErrors(): Array<String> {
        this.errors.toArray()
    }

    private func peekError(t: TokenType) {
        let msg = "expected next token to be ${t}, got ${this.peekToken.`type`} instead"
        this.errors.add(msg)
    }

    private func nextToken() {
        this.curToken = this.peekToken
        this.peekToken = this.lexer.nextToken()
    }

    public func parseProgram(): Program {
        let statements = ArrayList<Statement>()
        while (this.curToken.`type` != TokenType.EOF) {
            let stmt = this.parseStatement()
            if (let Some(statement) <- stmt) {
                statements.add(statement)
            }
            this.nextToken()
        }
        Program(statements.toArray())
    }

    private func registerPrefix(tokenType: TokenType, fn: prefixParseFn) {
        this.prefixParseFns[tokenType] = fn
    }

    private func registerInfix(tokenType: TokenType, fn: infixParseFn) {
        this.infixParseFns[tokenType] = fn
    }

    private func parseStatement(): ?Statement {
        match (this.curToken.`type`) {
            case TokenType.LET => this.parseLetStatement()
            case TokenType.RETURN => this.parseReturnStatement()
            case _ => this.parseExpressionStatement()
        }
    }

    private func parseExpressionStatement(): ExpressionStatement {
        let stmt = ExpressionStatement(this.curToken, this.parseExpression(LOWEST))

        if (this.peekTokenIs(TokenType.SEMICOLON)) {
            this.nextToken()
        }

        stmt
    }

    private func parseExpression(precedence: Int64): ?Expression {
        let prefix = this.prefixParseFns.get(this.curToken.`type`)
        if (let Some(fn) <- prefix) {
            var leftExp = fn()
            while (!this.peekTokenIs(TokenType.SEMICOLON) && precedence < this.peekPrecedence()) {
                if (let Some(infix) <- this.infixParseFns.get(this.peekToken.`type`) &&
                    let Some(lftExp) <- leftExp) {
                    this.nextToken()
                    leftExp = infix(lftExp)
                } else {
                    return leftExp
                }
            }

            return leftExp
        }
        this.noPrefixParseFnError(this.curToken.`type`)
        None
    }

    private func noPrefixParseFnError(t: TokenType) {
        let msg = "no prefix parse function for ${t} found"
        this.errors.add(msg)
    }

    private func parseIdentifier(): ?Expression {
        Identifier(this.curToken, this.curToken.literal)
    }

    private func parseIntegerLiteral(): ?Expression {
        if (let Some(value) <- Int64.tryParse(this.curToken.literal)) {
            let lit = IntegerLiteral(this.curToken, value)
            return lit
        }
        let msg = "could not parse ${this.curToken.literal} as integer"
        this.errors.add(msg)
        None
    }

    private func parsePrefixExpression(): ?Expression {
        let curToken = this.curToken
        this.nextToken()
        if (let Some(right) <- this.parseExpression(PREFIX)) {
            let expression = PrefixExpression(curToken, curToken.literal, right)
            return expression
        }
        let msg = "could not parse prefix expression with token ${curToken.literal}"
        this.errors.add(msg)
        None
    }

    private func parseBoolean(): ?Expression {
        Boolean(this.curToken, this.curTokenIs(TokenType.TRUE))
    }

    private func parseGroupedExpression(): ?Expression {
        this.nextToken()
        let exp = this.parseExpression(LOWEST)
        if (!this.expectPeek(TokenType.RPAREN)) {
            return None
        }
        exp
    }

    private func parseInfixExpression(left: Expression): ?Expression {
        let curToken = this.curToken
        let precedence = this.curPrecedence()
        this.nextToken()
        if (let Some(right) <- this.parseExpression(precedence)) {
            let expression = InfixExpression(
                curToken, left, curToken.literal,
                right,
            )
            return expression
        }
        let msg = "could not parse infix expression with token ${curToken.literal}"
        this.errors.add(msg)
        None
    }

    private func parseLetStatement(): ?Statement {
        let curToken = this.curToken
        if (!this.expectPeek(TokenType.IDENT)) {
            return None
        }

        let stmt = LetStatement(curToken, Identifier(this.curToken, this.curToken.literal), None)

        if (!this.expectPeek(TokenType.ASSIGN)) {
            return None
        }

        // TODO: 跳过对表达式的处理，直到遇见分号
        while (!this.curTokenIs(TokenType.SEMICOLON)) {
            this.nextToken()
        }

        stmt
    }

    private func parseReturnStatement(): Statement {
        let stmt = ReturnStatement(this.curToken, None)

        this.nextToken()

        // TODO: 跳过对表达式的处理，直到遇见分号
        while (!this.curTokenIs(TokenType.SEMICOLON)) {
            this.nextToken()
        }

        stmt
    }

    private func curTokenIs(t: TokenType): Bool {
        this.curToken.`type` == t
    }

    private func peekTokenIs(t: TokenType): Bool {
        this.peekToken.`type` == t
    }

    private func expectPeek(t: TokenType): Bool {
        if (this.peekTokenIs(t)) {
            this.nextToken()
            return true
        }
        this.peekError(t)
        false
    }
}
