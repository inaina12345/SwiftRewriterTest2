import XCTest
import SwiftRewriterLib
import IntentionPasses

class PropertyMergeIntentionPassTests: XCTestCase {
    func testMerge() {
        let intentions = IntentionCollection()
        let file = FileGenerationIntention(sourcePath: "a", filePath: "a")
        intentions.addIntention(file)
        let cls = ClassGenerationIntention(typeName: "A")
        cls.addProperty(PropertyGenerationIntention(name: "a", type: .int, attributes: []))
        cls.addMethod(MethodGenerationIntention(isStatic: false, name: "a", returnType: .int, parameters: []))
        cls.addMethod(MethodGenerationIntention(isStatic: false, name: "setA", returnType: .void,
                                                parameters: [ParameterSignature(label: "_", name: "a", type: .int)]))
        file.addType(cls)
        
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        switch cls.properties[0].mode {
        case .property:
            // Success
            break
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
    
    func testMergeReadonlyWithGetter() {
        let intentions = IntentionCollection()
        let file = FileGenerationIntention(sourcePath: "a", filePath: "a")
        intentions.addIntention(file)
        let cls = ClassGenerationIntention(typeName: "A")
        cls.addProperty(PropertyGenerationIntention(name: "a", type: .int, attributes: [.attribute("readonly")]))
        cls.addMethod(MethodGenerationIntention(isStatic: false, name: "a", returnType: .int, parameters: []))
        file.addType(cls)
        
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        switch cls.properties[0].mode {
        case .computed:
            // Success
            break
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
    
    func testMergeCategories() {
        let intentions = IntentionCollection()
        let file = FileGenerationIntention(sourcePath: "a", filePath: "a")
        intentions.addIntention(file)
        let cls = ClassExtensionGenerationIntention(typeName: "A")
        cls.addProperty(PropertyGenerationIntention(name: "a", type: .int, attributes: [.attribute("readonly")]))
        cls.addMethod(MethodGenerationIntention(isStatic: false, name: "a", returnType: .int, parameters: []))
        file.addType(cls)
        
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        switch cls.properties[0].mode {
        case .computed:
            // Success
            break
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
}

extension PropertyMergeIntentionPassTests {
    func makeContext(intentions: IntentionCollection) -> IntentionPassContext {
        let system = IntentionCollectionTypeSystem(intentions: intentions)
        let resolver = ExpressionTypeResolver(typeSystem: system)
        let invoker = DefaultTypeResolverInvoker(typeResolver: resolver)
        
        return IntentionPassContext(typeSystem: system, typeResolverInvoker: invoker)
    }
}
