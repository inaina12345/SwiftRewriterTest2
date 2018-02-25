import SwiftAST
import GrammarModels

/// An intention to create a .swift file
public class FileGenerationIntention: Intention {
    /// The source path for this file
    public var sourcePath: String
    
    /// The intended output file path
    public var filePath: String
    
    /// Gets the types to create on this file.
    private(set) var typeIntentions: [TypeGenerationIntention] = []
    
    /// All preprocessor directives found on this file.
    public var preprocessorDirectives: [String] = []
    
    /// Gets the class extensions (but not main class declarations) to create
    /// on this file.
    public var extensionIntentions: [ClassExtensionGenerationIntention] {
        return typeIntentions.compactMap { $0 as? ClassExtensionGenerationIntention }
    }
    
    /// Gets the classes (but not class extensions) to create on this file.
    public var classIntentions: [ClassGenerationIntention] {
        return typeIntentions.compactMap { $0 as? ClassGenerationIntention }
    }
    
    /// Gets the classes and class extensions to create on this file.
    public var classTypeIntentions: [BaseClassIntention] {
        return typeIntentions.compactMap { $0 as? BaseClassIntention }
    }
    
    /// Gets the protocols to create on this file.
    var protocolIntentions: [ProtocolGenerationIntention] {
        return typeIntentions.compactMap { $0 as? ProtocolGenerationIntention }
    }
    
    /// Gets the typealias intentions to create on this file.
    private(set) var typealiasIntentions: [TypealiasIntention] = []
    
    /// Gets the global functions to create on this file.
    private(set) var globalFunctionIntentions: [GlobalFunctionGenerationIntention] = []
    
    /// Gets the global variables to create on this file.
    private(set) var globalVariableIntentions: [GlobalVariableGenerationIntention] = []
    
    public var source: ASTNode?
    
    weak public var parent: Intention?
    
    public init(sourcePath: String, filePath: String) {
        self.sourcePath = sourcePath
        self.filePath = filePath
    }
    
    public func addType(_ intention: TypeGenerationIntention) {
        typeIntentions.append(intention)
        intention.parent = self
    }
    
    public func addTypealias(_ intention: TypealiasIntention) {
        typealiasIntentions.append(intention)
        intention.parent = self
    }
    
    public func removeTypes(where predicate: (TypeGenerationIntention) -> Bool) {
        for (i, type) in typeIntentions.enumerated().reversed() {
            if predicate(type) {
                type.parent = nil
                typeIntentions.remove(at: i)
            }
        }
    }
    
    public func removeClassTypes(where predicate: (BaseClassIntention) -> Bool) {
        for (i, type) in typeIntentions.enumerated().reversed() {
            if let classType = type as? BaseClassIntention, predicate(classType) {
                type.parent = nil
                typeIntentions.remove(at: i)
            }
        }
    }
    
    public func addProtocol(_ intention: ProtocolGenerationIntention) {
        typeIntentions.append(intention)
        intention.parent = self
    }
    
    public func addGlobalFunction(_ intention: GlobalFunctionGenerationIntention) {
        globalFunctionIntentions.append(intention)
        intention.parent = self
    }
    
    public func addGlobalVariable(_ intention: GlobalVariableGenerationIntention) {
        globalVariableIntentions.append(intention)
        intention.parent = self
    }
}

/// An intention to generate a global function.
public class GlobalFunctionGenerationIntention: FromSourceIntention, FunctionIntention {
    public var signature: FunctionSignature
    
    public var functionBody: FunctionBodyIntention?
    
    public init(signature: FunctionSignature, accessLevel: AccessLevel, source: ASTNode?) {
        self.signature = signature
        super.init(accessLevel: accessLevel, source: source)
    }
}

/// An intention to generate a global variable.
public class GlobalVariableGenerationIntention: FromSourceIntention, ValueStorageIntention {
    public var variableSource: VariableDeclaration? {
        return source as? VariableDeclaration
    }
    
    public var name: String
    public var storage: ValueStorage
    public var initialValueExpr: GlobalVariableInitialValueIntention?
    
    public init(name: String, storage: ValueStorage, accessLevel: AccessLevel = .internal,
                source: ASTNode? = nil) {
        self.name = name
        self.storage = storage
        super.init(accessLevel: accessLevel, source: source)
    }
}

/// An intention to generate the initial value for a global variable.
public class GlobalVariableInitialValueIntention: FromSourceIntention {
    public var expression: Expression
    
    public init(expression: Expression, source: ASTNode?) {
        self.expression = expression
        
        super.init(accessLevel: .public, source: source)
    }
}

/// Represents an intention that has a value associated that indicates whether it
/// was defined within NS_ASSUME_NONNULL contexts
public protocol NonNullScopedIntention: Intention {
    /// Gets a value indicating whether this intention was defined within
    /// NS_ASSUME_NONNULL contexts
    var inNonnullContext: Bool { get }
}

/// Defines a protocol for function-generating intentions
public protocol FunctionIntention: Intention {
    var signature: FunctionSignature { get }
    
    var functionBody: FunctionBodyIntention? { get }
}

/// Signature for a function intention
public struct FunctionSignature: Equatable {
    public var isStatic: Bool
    public var name: String
    public var returnType: SwiftType
    public var parameters: [ParameterSignature]
    
    public init(name: String, parameters: [ParameterSignature], returnType: SwiftType = .void, isStatic: Bool = false) {
        self.isStatic = isStatic
        self.name = name
        self.returnType = returnType
        self.parameters = parameters
    }
    
    /// Returns a `SwiftType.block`-equivalent type for this function signature
    public var swiftClosureType: SwiftType {
        return .block(returnType: returnType, parameters: parameters.map { $0.type })
    }
    
    public var droppingNullability: FunctionSignature {
        let parameters = self.parameters.map {
            ParameterSignature(label: $0.label, name: $0.name, type: $0.type.deepUnwrapped)
        }
        
        return FunctionSignature(name: name,
                                 parameters: parameters,
                                 returnType: returnType.deepUnwrapped,
                                 isStatic: isStatic)
    }
    
    /// Returns `true` iff `self` and `other` match using Objective-C signature
    /// matching rules.
    public func matchesAsSelector(_ other: FunctionSignature) -> Bool {
        if isStatic != other.isStatic {
            return false
        }
        if name != other.name {
            return false
        }
        if parameters.count != other.parameters.count {
            return false
        }
        
        for (p1, p2) in zip(parameters, other.parameters) {
            if p1.label != p2.label {
                return false
            }
        }
        
        return true
    }
}

public struct ParameterSignature: Equatable {
    public var label: String
    public var name: String
    public var type: SwiftType
    
    public init(label: String, name: String, type: SwiftType) {
        self.label = label
        self.name = name
        self.type = type
    }
}

/// Defines a protocol for a value storage intention.
public protocol ValueStorageIntention: Intention {
    var name: String { get }
    var storage: ValueStorage { get }
}

public extension ValueStorageIntention {
    public var type: SwiftType {
        return storage.type
    }
    
    public var ownership: Ownership {
        return storage.ownership
    }
    
    public var isConstant: Bool {
        return storage.isConstant
    }
}
