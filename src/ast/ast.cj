package thunderlang.ast

import thunderlang.token.Token

public interface Node {
    func tokenLiteral(): String
    func string(): String
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

    public func string(): String {
        let sb = StringBuilder()

        for (s in this.statements) {
            sb.append(s.string())
        }

        sb.toString()
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

    public func string(): String {
        let sb = StringBuilder()

        sb.append(this.tokenLiteral() + " ")
        sb.append(this.name.string())
        sb.append(" = ")
        if (let Some(val) <- this.value) {
            sb.append(val.string())
        }
        sb.append(";")

        sb.toString()
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

    public func string(): String {
        let sb = StringBuilder()

        sb.append(this.tokenLiteral() + " ")
        if (let Some(val) <- this.returnValue) {
            sb.append(val.string())
        }
        sb.append(";")

        sb.toString()
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

    public func string(): String {
        this.value
    }
}

public struct ExpressionStatement <: Statement {
    public ExpressionStatement(
        public let token: Token,
        public let expression: ?Expression
    ) {
    }

    public func tokenLiteral(): String {
        this.token.literal
    }

    public func statementNode(): Unit {
    }

    public func string(): String {
        if (let Some(expr) <- this.expression) {
            return expr.string()
        }
        ""
    }
}

public struct IntegerLiteral <: Expression {
    public IntegerLiteral(
        public let token: Token,
        public let value: Int64
    ) {
    }

    public func tokenLiteral(): String {
        this.token.literal
    }

    public func expressionNode(): Unit {
    }

    public func string(): String {
        this.token.literal
    }
}

public struct PrefixExpression <: Expression {
    public PrefixExpression(
        public let token: Token,
        public let `operator`: String,
        public let right: Expression
    ) {
    }

    public func tokenLiteral(): String {
        this.token.literal
    }

    public func expressionNode(): Unit {
    }

    public func string(): String {
        let sb = StringBuilder()

        sb.append("(")
        sb.append(this.`operator`)
        sb.append(this.right.string())
        sb.append(")")

        sb.toString()
    }
}
