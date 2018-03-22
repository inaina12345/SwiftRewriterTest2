import XCTest
import SwiftAST

class SwiftTypeTests: XCTestCase {
    func testDescriptionTypeName() {
        XCTAssertEqual(SwiftType.typeName("A").description,
                       "A")
    }
    
    func testDescriptionGeneric() {
        XCTAssertEqual(SwiftType.generic("A", parameters: [.typeName("B")]).description,
                       "A<B>")
        XCTAssertEqual(SwiftType.generic("A", parameters: [.typeName("B"), .typeName("C")]).description,
                       "A<B, C>")
    }
    
    func testDescriptionProtocolComposition() {
        // These are not valid and will crash, since protocol compositions require
        // two or more nominal types.
        //
        // XCTAssertEqual(SwiftType.protocolComposition([]).description,
        //                "")
        //
        // XCTAssertEqual(SwiftType.protocolComposition([.typeName("A")]).description,
        //                "A")
        XCTAssertEqual(SwiftType.protocolComposition([.typeName("A"), .typeName("B")]).description,
                       "A & B")
        XCTAssertEqual(SwiftType.protocolComposition([.typeName("A"), .typeName("B"), .typeName("C")]).description,
                       "A & B & C")
    }
    
    func testDescriptionNestedType() {
        XCTAssertEqual(SwiftType.nested([.typeName("A"), .typeName("B")]).description,
                       "A.B")
        XCTAssertEqual(SwiftType.nested([.generic("A", parameters: [.typeName("B")]), .typeName("C")]).description,
                       "A<B>.C")
        XCTAssertEqual(SwiftType.nested([.typeName("A"), .typeName("B"), .typeName("C")]).description,
                       "A.B.C")
    }
    
    func testDescriptionMetadata() {
        XCTAssertEqual(SwiftType.metatype(for: .typeName("A")).description,
                       "A.Type")
        XCTAssertEqual(SwiftType.metatype(for: .metatype(for: .typeName("A"))).description,
                       "A.Type.Type")
    }
    
    func testDescriptionTupleType() {
        XCTAssertEqual(SwiftType.tuple(.empty).description,
                       "Void")
        
        // This is not valid and will crash, since tuples require either 0, or
        // two or more types
        //
        // XCTAssertEqual(SwiftType.tuple([.typeName("A")]).description,
        //                "(A)")
        
        XCTAssertEqual(SwiftType.tuple(.types([.typeName("A"), .typeName("B")])).description,
                       "(A, B)")
        XCTAssertEqual(SwiftType.tuple(.types([.typeName("A"), .typeName("B"), .typeName("C")])).description,
                       "(A, B, C)")
    }
    
    func testDescriptionBlockType() {
        XCTAssertEqual(SwiftType.block(returnType: .void, parameters: []).description,
                       "() -> Void")
    }
    
    func testDescriptionBlockTypeWithReturnType() {
        XCTAssertEqual(SwiftType.block(returnType: .typeName("A"), parameters: []).description,
                       "() -> A")
    }
    
    func testDescriptionBlockTypeWithParameters() {
        XCTAssertEqual(SwiftType.block(returnType: .void, parameters: [.typeName("A")]).description,
                       "(A) -> Void")
        XCTAssertEqual(SwiftType.block(returnType: .void, parameters: [.typeName("A"), .typeName("B")]).description,
                       "(A, B) -> Void")
    }
    
    func testDescriptionBlockFull() {
        XCTAssertEqual(SwiftType.block(returnType: .typeName("A"), parameters: [.typeName("B"), .typeName("C")]).description,
                       "(B, C) -> A")
    }
    
    func testDescriptionOptionalWithTypeName() {
        XCTAssertEqual(SwiftType.optional(.typeName("A")).description,
                       "A?")
    }
    
    func testDescriptionOptionalWithProtocolCompositionType() {
        XCTAssertEqual(SwiftType.optional(.protocolComposition([.typeName("A"), .typeName("B")])).description,
                       "(A & B)?")
    }
    
    func testDescriptionOptionalWithTupleType() {
        XCTAssertEqual(SwiftType.optional(.tuple(.types([.typeName("A"), .typeName("B")]))).description,
                       "(A, B)?")
    }
    
    func testDescriptionOptionalWithBlockTupleType() {
        XCTAssertEqual(SwiftType.optional(.block(returnType: .void, parameters: [.typeName("A"), .typeName("B")])).description,
                       "((A, B) -> Void)?")
    }
    
    func testDescriptionOptionalWithGenericType() {
        XCTAssertEqual(SwiftType.optional(.generic("A", parameters: .fromCollection([.typeName("B"), .typeName("C")]))).description,
                       "A<B, C>?")
    }
    
    func testDescriptionOptionalWithNestedType() {
        XCTAssertEqual(SwiftType.optional(.nested([.typeName("A"), .typeName("B")])).description,
                       "A.B?")
    }
    
    func testDescriptionOptionalWithProtocolComposition() {
        XCTAssertEqual(SwiftType.optional(.protocolComposition([.typeName("A"), .typeName("B")])).description,
                       "(A & B)?")
    }
    
    func testDescriptionOptionalWithOptionalType() {
        XCTAssertEqual(SwiftType.optional(.optional(.typeName("A"))).description,
                       "A??")
    }
    
    func testDescriptionImplicitOptionalWithOptionalType() {
        XCTAssertEqual(SwiftType.implicitUnwrappedOptional(.optional(.typeName("A"))).description,
                       "A?!")
    }
    
    func testDescriptionImplicitOptionalWithTypeName() {
        XCTAssertEqual(SwiftType.implicitUnwrappedOptional(.typeName("A")).description,
                       "A!")
    }
    
    func testDescriptionArrayType() {
        XCTAssertEqual(SwiftType.array(.typeName("A")).description,
                       "[A]")
    }
    
    func testDescriptionDictionaryType() {
        XCTAssertEqual(SwiftType.dictionary(key: .typeName("A"), value: .typeName("B")).description,
                       "[A: B]")
    }
    
    func testWithSameOptionalityAs() {
        XCTAssertEqual(
            SwiftType.int.withSameOptionalityAs(.any),
            .int
        )
        XCTAssertEqual(
            SwiftType.int.withSameOptionalityAs(.optional(.any)),
            .optional(.int)
        )
        XCTAssertEqual(
            SwiftType.int.withSameOptionalityAs(.optional(.implicitUnwrappedOptional(.any))),
            .optional(.implicitUnwrappedOptional(.int))
        )
        XCTAssertEqual(
            SwiftType.optional(.int).withSameOptionalityAs(.any),
            .int
        )
        XCTAssertEqual(
            SwiftType.optional(.int).withSameOptionalityAs(.optional(.implicitUnwrappedOptional(.any))),
            .optional(.implicitUnwrappedOptional(.int))
        )
    }
    
    func testEncode() throws {
        let type = SwiftType.block(returnType: .void, parameters: [.array(.string)])
        
        let encoded = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(SwiftType.self, from: encoded)
        
        XCTAssertEqual(type, decoded)
    }
    
    func testEncodeEmptyTuple() throws {
        let type = SwiftType.tuple(.empty)
        
        let encoded = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(SwiftType.self, from: encoded)
        
        XCTAssertEqual(type, decoded)
    }
    
    func testEncodeSingleTypeTuple() throws {
        let type = SwiftType.tuple(.types([.int, .string]))
        
        let encoded = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(SwiftType.self, from: encoded)
        
        XCTAssertEqual(type, decoded)
    }
    
    func testEncodeTwoTypedTuple() throws {
        let type = SwiftType.tuple(.types([.int, .string]))
        
        let encoded = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(SwiftType.self, from: encoded)
        
        XCTAssertEqual(type, decoded)
    }
    
    func testEncodeNAryTypedTuple() throws {
        let type = SwiftType.tuple(.types([.int, .string, .float, .double, .any]))
        
        let encoded = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(SwiftType.self, from: encoded)
        
        XCTAssertEqual(type, decoded)
    }
    
    func testEncodeAsNested() throws {
        struct Test: Codable {
            var type: SwiftType
        }
        
        let test =
            Test(type: .block(returnType: .implicitUnwrappedOptional(.protocolComposition([.typeName("A"), .typeName("B")])),
                              parameters: [.generic("C", parameters: [.optional(.nested([.typeName("D"), .generic("E", parameters: [.typeName("D")])]))])]))
        
        let encoded = try JSONEncoder().encode(test)
        let decoded = try JSONDecoder().decode(Test.self, from: encoded)
        
        XCTAssertEqual(test.type, decoded.type)
    }
}
