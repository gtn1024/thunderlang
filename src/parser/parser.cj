package thunderlang.parser

import thunderlang.lexer.Lexer
import thunderlang.token.{Token, TokenType}
import thunderlang.ast.{Program, Statement, Expression, LetStatement, Identifier}
import std.collection.ArrayList

public class Parser {
    private var curToken: Token = Token(TokenType.EOF, "")
    private var peekToken: Token = Token(TokenType.EOF, "")

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
        false
    }
}
