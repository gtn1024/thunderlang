package thunderlang.ast

import thunderlang.token.Token

public interface Node {
    func tokenLiteral(): String
}

public interface Statement <: Node {
    func statementNode(): Unit
}

public interface Expression <: Node {
    func expressionNode(): Unit
}

public struct Program <: Node {
    public Program(public let statements: Array<Statement>) {
    }

    public func tokenLiteral(): String {
        if (this.statements.size > 0) {
            return this.statements[0].tokenLiteral()
        }
        ""
    }
}

public struct LetStatement <: Statement {
    public LetStatement(
        public let token: Token,
        public let name: Identifier,
        public let value: ?Expression
    ) {
    }

    public func tokenLiteral(): String {
        this.token.literal
    }

    public func statementNode(): Unit {
    }
}

public struct ReturnStatement <: Statement {
    public ReturnStatement(
        public let token: Token,
        public let returnValue: ?Expression
    ) {
    }

    public func tokenLiteral(): String {
        this.token.literal
    }

    public func statementNode(): Unit {
    }
}

public struct Identifier <: Expression {
    public Identifier(
        public let token: Token,
        public let value: String
    ) {
    }

    public func tokenLiteral(): String {
        this.token.literal
    }

    public func expressionNode(): Unit {
    }
}
