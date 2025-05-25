package thunderlang.parser

import thunderlang.lexer.Lexer
import thunderlang.token.{Token, TokenType}
import thunderlang.ast.{Program, Statement, Expression, LetStatement, ReturnStatement, Identifier}
import std.collection.ArrayList

public class Parser {
    private var curToken: Token = Token(TokenType.EOF, "")
    private var peekToken: Token = Token(TokenType.EOF, "")
    private let errors: ArrayList<String> = ArrayList()

    public Parser(
        private let lexer: Lexer
    ) {
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

    private func parseStatement(): ?Statement {
        match (this.curToken.`type`) {
            case TokenType.LET => this.parseLetStatement()
            case TokenType.RETURN => this.parseReturnStatement()
            case _ => None
        }
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
