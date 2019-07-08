public typealias SyntaxMatcher<T> = ValueMatcher<T> where T: SyntaxNode

public extension ValueMatcher where T: SyntaxNode {
    
    @inlinable
    func anySyntaxNode() -> ValueMatcher<SyntaxNode> {
        ValueMatcher<SyntaxNode>().match { (value) -> Bool in
            if let value = value as? T {
                return self.matches(value)
            }
            
            return false
        }
    }
    
}

// FIXME: Inline again once Linux bug is corrected
// https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
// @inlinable
public func ident(_ string: String) -> SyntaxMatcher<IdentifierExpression> {
    SyntaxMatcher().keyPath(\.identifier, equals: string)
}

// FIXME: Inline again once Linux bug is corrected
// https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
// @inlinable
public func ident(_ matcher: MatchRule<String>) -> SyntaxMatcher<IdentifierExpression> {
    SyntaxMatcher().keyPath(\.identifier, matcher)
}

public extension ValueMatcher where T: Expression {
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func isTyped(_ type: SwiftType, ignoringNullability: Bool = false) -> ValueMatcher {
        if !ignoringNullability {
            return keyPath(\.resolvedType, equals: type)
        }
        
        return keyPath(\.resolvedType, .closure { $0?.deepUnwrapped == type })
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func isTyped(expected type: SwiftType, ignoringNullability: Bool = false) -> ValueMatcher {
        if !ignoringNullability {
            return keyPath(\.expectedType, equals: type)
        }
        
        return keyPath(\.expectedType, .closure { $0?.deepUnwrapped == type })
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func dot<S>(_ member: S) -> SyntaxMatcher<PostfixExpression>
        where S: ValueMatcherConvertible, S.Target == String {
        
        SyntaxMatcher<PostfixExpression>()
            .match(.closure { postfix -> Bool in
                guard let exp = postfix.exp as? T else {
                    return false
                }
                
                return self.matches(exp)
            })
            .keyPath(\.op.asMember?.name, member.asMatcher())
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func subscribe<E>(_ matcher: E) -> SyntaxMatcher<PostfixExpression>
        where E: ValueMatcherConvertible, E.Target == Expression {
            
        SyntaxMatcher<PostfixExpression>()
            .match(.closure { postfix -> Bool in
                guard let exp = postfix.exp as? T else {
                    return false
                }
                
                return self.matches(exp)
            })
            .keyPath(\.op.asSubscription?.expression, matcher.asMatcher())
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func call(_ args: [FunctionArgument]) -> SyntaxMatcher<PostfixExpression> {
        SyntaxMatcher<PostfixExpression>()
            .match { postfix -> Bool in
                guard let exp = postfix.exp as? T else {
                    return false
                }
                
                return self.matches(exp)
            }
            .keyPath(\.op.asFunctionCall?.arguments, equals: args)
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func call(arguments matchers: [ValueMatcher<FunctionArgument>]) -> SyntaxMatcher<PostfixExpression> {
        SyntaxMatcher<PostfixExpression>()
            .match { postfix -> Bool in
                guard let exp = postfix.exp as? T else {
                    return false
                }
                
                return self.matches(exp)
            }
            .keyPath(\.op.asFunctionCall?.arguments.count, equals: matchers.count)
            .keyPath(\.op.asFunctionCall?.arguments) { args -> ValueMatcher<[FunctionArgument]> in
                args.match(closure: { args -> Bool in
                    for (matcher, arg) in zip(matchers, args) {
                        if !matcher.matches(arg) {
                            return false
                        }
                    }
                    
                    return true
                })
            }
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func call(_ method: String) -> SyntaxMatcher<PostfixExpression> {
        dot(method).call([])
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func binary<E>(op: SwiftOperator, rhs: E) -> SyntaxMatcher<BinaryExpression>
        where E: ValueMatcherConvertible, E.Target == Expression {
                
        SyntaxMatcher<BinaryExpression>()
            .keyPath(\.op, .equals(op))
            .keyPath(\.rhs, rhs.asMatcher())
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func assignment<E>(op: SwiftOperator, rhs: E) -> SyntaxMatcher<AssignmentExpression>
        where E: ValueMatcherConvertible, E.Target == Expression {
        
        SyntaxMatcher<AssignmentExpression>()
            .keyPath(\.op, .equals(op))
            .keyPath(\.rhs, rhs.asMatcher())
    }
}

public extension ValueMatcher where T == FunctionArgument {
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func isLabeled(as label: String) -> ValueMatcher {
        ValueMatcher().keyPath(\.label, equals: label)
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isNotLabeled: ValueMatcher {
        ValueMatcher().keyPath(\.label, isNil())
    }
}

public extension ValueMatcher where T: PostfixExpression {
    
    typealias PostfixMatcher = ValueMatcher<[PostfixChainInverter.Postfix]>
    
    /// Matches if the postfix is a function invocation.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isFunctionCall: ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.op, .isType(FunctionCallPostfix.self))
    }
    
    /// Matches if the postfix is a member access.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isMemberAccess: ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.op, .isType(MemberPostfix.self))
    }
    
    /// Matches if the postfix is a subscription.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isSubscription: ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.op, .isType(SubscriptPostfix.self))
    }
    
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func isMemberAccess(forMember name: String) -> ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.op, .isType(MemberPostfix.self))
    }
    
    /// Opens a context for matching postfix operation chains using an inverted
    /// traversal method (left-most to right-most).
    ///
    /// Inversion is required due to the disposition of the syntax tree of postfix
    /// expressions: the top node is always the last postfix invocation of the
    /// chain, while the bottom-most postfix node is the first invocation.
    ///
    /// - Parameter closure: A closure that matches postfix expressions from
    /// leftmost to rightmost.
    /// - Returns: A new `PostfixExpression` matcher with the left-to-right
    /// postfix matcher constructed using the closure.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func inverted(_ closure: (PostfixMatcher) -> PostfixMatcher) -> ValueMatcher<T> {
        
        let matcher = closure(PostfixMatcher())
        
        return match { value -> Bool in
            let chain = PostfixChainInverter(expression: value).invert()
            
            return matcher.matches(chain)
        }
    }
}

public extension ValueMatcher where T == PostfixChainInverter.Postfix {
    
    /// Matches if the postfix is a function invocation.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isFunctionCall: ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.postfix, .isType(FunctionCallPostfix.self))
    }
    
    /// Matches if the postfix is a member access.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isMemberAccess: ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.postfix, .isType(MemberPostfix.self))
    }
    
    /// Matches if the postfix is a subscription.
    // FIXME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var isSubscription: ValueMatcher<T> {
        ValueMatcher<T>()
            .keyPath(\.postfix, .isType(SubscriptPostfix.self))
    }
    
}

public extension ValueMatcher where T: Expression {
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    func anyExpression() -> ValueMatcher<Expression> {
        ValueMatcher<Expression>().match { (value) -> Bool in
            if let value = value as? T {
                return self.matches(value)
            }
            
            return false
        }
    }
    
}

public extension ValueMatcher where T: Expression {
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static var `nil`: ValueMatcher<Expression> {
        ValueMatcher<Expression>().match { exp in
            guard let constant = exp as? ConstantExpression else {
                return false
            }
            
            return constant.constant == .nil
        }
    }
    
    // TODO: Revert implementation from both methods bellow to use `exp.asMatchable()`
    // and comparisons with dynamic matchers.
    // Currently, they crash the compiler on Xcode 10 beta 5.
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func nilCheck(against value: Expression) -> ValueMatcher<Expression> {
        ValueMatcher<Expression>().match { exp in
            let valueCopy = value.copy()
            
            // <exp> != nil
            if exp == .binary(lhs: valueCopy, op: .unequals, rhs: .constant(.nil)) {
                return true
            }
            // nil != <exp>
            if exp == .binary(lhs: .constant(.nil), op: .unequals, rhs: valueCopy) {
                return true
            }
            // <exp>
            if exp == valueCopy {
                return true
            }
            
            return false
        }
    }
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func nilCompare(against value: Expression) -> ValueMatcher<Expression> {
        ValueMatcher<Expression>().match { exp in
            let valueCopy = value.copy()
            
            // <exp> == nil
            if exp == .binary(lhs: valueCopy, op: .equals, rhs: .constant(.nil)) {
                return true
            }
            // nil == <exp>
            if exp == .binary(lhs: .constant(.nil), op: .equals, rhs: valueCopy) {
                return true
            }
            // !<exp>
            if exp == .unary(op: .negate, valueCopy) {
                return true
            }
            
            return false
        }
    }
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func findAny(thatMatches matcher: ValueMatcher) -> ValueMatcher {
        ValueMatcher().match { exp in
            
            let sequence = SyntaxNodeSequence(node: exp, inspectBlocks: false)
            
            for e in sequence.compactMap({ $0 as? T }) {
                if matcher.matches(e) {
                    return true
                }
            }
            
            return false
        }
    }
    
}

public extension ValueMatcher where T == Expression {
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func unary<O, E>(op: O, _ exp: E) -> ValueMatcher<Expression>
        where O: ValueMatcherConvertible, E: ValueMatcherConvertible,
        O.Target == SwiftOperator, E.Target == Expression {
        
        ValueMatcher<UnaryExpression>()
                .keyPath(\.op, op.asMatcher())
                .keyPath(\.exp, exp.asMatcher())
                .anyExpression()
    }
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func binary<O, E>(lhs: E, op: O, rhs: E) -> ValueMatcher<Expression>
        where O: ValueMatcherConvertible, E: ValueMatcherConvertible,
        O.Target == SwiftOperator, E.Target == Expression {
        
        ValueMatcher<BinaryExpression>()
                .keyPath(\.lhs, lhs.asMatcher())
                .keyPath(\.op, op.asMatcher())
                .keyPath(\.rhs, rhs.asMatcher())
                .anyExpression()
    }
    
}

public extension Expression {
    
    func asMatchable() -> ExpressionMatchable {
        ExpressionMatchable(exp: self)
    }
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    static func matcher<T: Expression>(_ matcher: SyntaxMatcher<T>) -> SyntaxMatcher<T> {
        matcher
    }
    
}

public struct ExpressionMatchable {
    public var exp: Expression
    
    // FIX-ME: Inline again once Linux bug is corrected
    // https://dev.azure.com/luiz-fs/SwiftRewriter/_build/results?buildId=375&view=logs&jobId=0da5d1d9-276d-5173-c4c4-9d4d4ed14fdb&taskId=8ef82b3b-1feb-5bbd-06f6-b1f7b5467f03&lineStart=71&lineEnd=71&colStart=243&colEnd=301
    // @inlinable
    public static func == (lhs: ExpressionMatchable, rhs: ValueMatcher<Expression>) -> Bool {
        lhs.exp.matches(rhs)
    }
}

extension Expression: Matchable {
    
}

extension Expression: ValueMatcherConvertible {
    
}
extension SwiftOperator: ValueMatcherConvertible {
    
}
extension SwiftType: ValueMatcherConvertible {
    
}
extension String: ValueMatcherConvertible {
    
}
