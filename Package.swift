// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "SwiftRewriter",
    products: [
        // Products define the executables and libraries produced by a package,
        // and make them visible to other packages.
        .library(
            name: "SwiftRewriterLib",
            targets: ["SwiftRewriterLib"]),
        .library(
            name: "ObjcParser",
            targets: ["ObjcParser"]),
        .executable(
            name: "SwiftRewriter",
            targets: ["SwiftRewriter"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/LuizZak/MiniLexer.git", from: "0.7.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
        .package(url: "https://github.com/LuizZak/antlr4-swift.git", from: "4.0.24"),
        .package(url: "https://github.com/LuizZak/console.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.40200.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define
        // a module or a test suite.
        // Targets can depend on other targets in this package, and on products
        // in packages which this package depends on.
        .target(
            name: "TypeDefinitions",
            dependencies: []),
        .target(
            name: "Utils",
            dependencies: []),
        .target(
            name: "WriterTargetOutput",
            dependencies: []),
        .target(
            name: "ObjcParserAntlr",
            dependencies: ["Antlr4"]),
        .target(
            name: "GrammarModels",
            dependencies: ["ObjcParserAntlr"]),
        .target(
            name: "ObjcParser",
            dependencies: ["ObjcParserAntlr", "Antlr4", "GrammarModels", "MiniLexer",
                           "TypeLexing", "Utils"]),
        .target(
            name: "SwiftAST",
            dependencies: ["GrammarModels", "MiniLexer"]),
        .target(
            name: "KnownType",
            dependencies: ["SwiftAST", "WriterTargetOutput"]),
        .target(
            name: "SwiftSyntaxSupport",
            dependencies: ["SwiftSyntax", "KnownType", "Intentions", "SwiftAST"]),
        .target(
            name: "Intentions",
            dependencies: ["SwiftAST", "GrammarModels", "KnownType"]),
        .target(
            name: "TypeSystem",
            dependencies: ["SwiftAST", "ObjcParser", "TypeDefinitions", "Utils",
                           "Intentions", "KnownType", "GrammarModels"]),
        .target(
            name: "SwiftRewriterLib",
            dependencies: ["GrammarModels", "SwiftAST", "ObjcParser",
                           "TypeDefinitions", "Utils", "Intentions", "TypeSystem",
                           "IntentionPasses", "KnownType", "WriterTargetOutput",
                           "SwiftSyntaxSupport"]),
        .target(
            name: "Commons",
            dependencies: ["SwiftAST", "Utils", "TypeSystem", "KnownType"]),
        .target(
            name: "IntentionPasses",
            dependencies: ["SwiftAST", "Commons", "Utils", "MiniLexer",
                           "Intentions"]),
        .target(
            name: "GlobalsProviders",
            dependencies: ["SwiftRewriterLib", "SwiftAST", "Commons"]),
        .target(
            name: "ExpressionPasses",
            dependencies: ["SwiftRewriterLib", "SwiftAST", "Commons", "Utils",
                           "Intentions"]),
        .target(
            name: "SourcePreprocessors",
            dependencies: ["SwiftRewriterLib", "Utils", "MiniLexer"]),
        .target(
            name: "SwiftRewriter",
            dependencies: [
                "SwiftRewriterLib", "ObjcParser", "GrammarModels", "Utility",
                "ExpressionPasses", "Utils", "Console", "SourcePreprocessors",
                "SwiftAST", "IntentionPasses", "MiniLexer", "GlobalsProviders",
                "Commons"
            ]),
        .target(
            name: "TestCommons",
            dependencies: [
                "SwiftAST", "SwiftRewriterLib", "Intentions", "KnownType",
                "GrammarModels", "Utils", "TypeSystem"
            ])
        
    ] + /* Tests */ [
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]),
        .testTarget(
            name: "ObjcParserTests",
            dependencies: ["GrammarModels", "ObjcParser"]),
        .testTarget(
            name: "GrammarModelsTests",
            dependencies: ["GrammarModels"]),
        .testTarget(
            name: "SwiftASTTests",
            dependencies: ["SwiftAST",
                           "TestCommons",
                           // TODO: We use this SwiftRewriterLib dependency here
                           // to print AST's in a test for debugging purposes.
                           // Attempt to abstract a simple AST-to-string functionality
                           // to TestCommons and use that one, instead.
                           "SwiftRewriterLib"]),
        .testTarget(
            name: "IntentionsTests",
            dependencies: ["TestCommons", "SwiftAST", "Intentions"]),
        .testTarget(
            name: "KnownTypeTests",
            dependencies: ["TestCommons", "SwiftAST", "KnownType", "WriterTargetOutput"]),
        .testTarget(
            name: "SwiftSyntaxSupportTests",
            dependencies: ["SwiftSyntaxSupport", "SwiftSyntax", "KnownType",
                           "Intentions", "SwiftAST", "TestCommons",
                           "SwiftRewriterLib"]),
        .testTarget(
            name: "TypeSystemTests",
            dependencies: ["TypeSystem", "SwiftAST", "ObjcParser",
                           "TypeDefinitions", "Utils", "Intentions",
                           "GrammarModels", "KnownType", "TestCommons",
                           "GlobalsProviders"]),
        .testTarget(
            name: "SwiftRewriterLibTests",
            dependencies: ["SwiftRewriterLib", "SwiftAST", "GrammarModels",
                           "ObjcParser", "ExpressionPasses", "IntentionPasses",
                           "TestCommons", "GlobalsProviders", "Intentions",
                           "TypeSystem", "WriterTargetOutput", "SwiftSyntaxSupport"]),
        .testTarget(
            name: "CommonsTests",
            dependencies: ["Commons", "SwiftAST", "KnownType", "SwiftRewriterLib",
                           "TypeSystem"]),
        .testTarget(
            name: "ExpressionPassesTests",
            dependencies: ["ExpressionPasses", "SwiftAST", "SwiftRewriterLib",
                           "Antlr4", "ObjcParser", "ObjcParserAntlr",
                           "IntentionPasses", "GlobalsProviders",
                           "TypeSystem"]),
        .testTarget(
            name: "SourcePreprocessorsTests",
            dependencies: ["SourcePreprocessors", "Utils", "SwiftRewriterLib",
                           "IntentionPasses", "GlobalsProviders"]),
        .testTarget(
            name: "IntentionPassesTests",
            dependencies: ["SwiftAST", "GrammarModels", "SwiftRewriterLib",
                           "IntentionPasses", "TestCommons", "GlobalsProviders",
                           "TypeSystem"]),
        .testTarget(
            name: "GlobalsProvidersTests",
            dependencies: ["SwiftAST", "SwiftRewriterLib", "GlobalsProviders",
                           "TestCommons", "TypeSystem"]),
        .testTarget(
            name: "TestCommonsTests",
            dependencies: ["TestCommons", "Utils", "TypeSystem"])
    ],
    swiftLanguageVersions: [.v4_2]
)
