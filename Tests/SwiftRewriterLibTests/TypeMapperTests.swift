import XCTest
import SwiftRewriterLib
import ObjcParser
import GrammarModels

class TypeMapperTests: XCTestCase {
    func testMapSimpleTypes() {
        expect(.specified(specifiers: ["const"], .struct("NSInteger")),
               toConvertTo: "Int")
        
        expect(.specified(specifiers: ["const"], .struct("NSInteger")),
               withExplicitNullability: nil,
               toConvertTo: "Int")
        
        expect(.struct("NSInteger"), toConvertTo: "Int")
        
        expect(.struct("BOOL"), toConvertTo: "Bool")
        
        expect(.struct("CGColor"), toConvertTo: "CGColor")
        
        expect(.pointer(.struct("NSString")),
               toConvertTo: "String")
        
        expect(.pointer(.struct("NSObject")),
               toConvertTo: "NSObject")
        
        expect(.id(protocols: []),
               toConvertTo: "AnyObject")
        
        expect(.id(protocols: ["UITableViewDelegate"]),
               withExplicitNullability: .nullable,
               toConvertTo: "AnyObject<UITableViewDelegate>?")
        
        expect(.pointer(.generic("NSArray", parameters: [.struct("NSInteger")])),
               toConvertTo: "[Int]")
        
        expect(.pointer(.generic("NSArray", parameters: [.pointer(.struct("NSString"))])),
               toConvertTo: "[String]")
        
        expect(.pointer(.generic("NSArray", parameters: [])),
               toConvertTo: "NSArray")
        expect(.pointer(.struct("NSArray")),
               toConvertTo: "NSArray")
        
        expect(.struct("instancetype"),
               toConvertTo: "AnyObject")
        
        expect(.specified(specifiers: ["__weak"], .id(protocols: [])),
               withExplicitNullability: nil,
               toConvertTo: "AnyObject?")
    }
    
    func testConcreteTypesWithProtocol() {
        expect(.pointer(.generic("UIView", parameters: [.struct("UIDelegate")])),
               toConvertTo: "UIView & UIDelegate")
        expect(.pointer(.generic("UIView", parameters: [.struct("UIDelegate")])),
               withExplicitNullability: .nullable,
               toConvertTo: "(UIView & UIDelegate)?")
    }
    
    func testBlockTypes() {
        expect(.blockType(name: "block", returnType: .void, parameters: []),
               toConvertTo: "() -> Void")
        
        expect(.blockType(name: "block", returnType: .struct("NSInteger"), parameters: []),
               toConvertTo: "() -> Int")
        
        expect(.blockType(name: "block", returnType: .struct("NSInteger"), parameters: [.pointer(.struct("NSString")), .pointer(.struct("NSString"))]),
               toConvertTo: "(String, String) -> Int")
        expect(.blockType(name: "block", returnType: .struct("NSInteger"), parameters: [.qualified(.pointer(.struct("NSString")), qualifiers: ["_Nullable"]), .pointer(.struct("NSString"))]),
               withExplicitNullability: nil,
               toConvertTo: "(String?, String!) -> Int")
    }
    
    func testQualifiedWithinSpecified() {
        expect(.specified(specifiers: ["static"], .qualified(.pointer(.struct("NSString")), qualifiers: ["_Nullable"])),
               withExplicitNullability: nil,
               toConvertTo: "String?")
        expect(.specified(specifiers: ["__weak"], .qualified(.pointer(.struct("NSString")), qualifiers: ["const"])),
               withExplicitNullability: nil,
               toConvertTo: "String?")
    }
    
    private func expect(_ type: ObjcType, withExplicitNullability nullability: TypeNullability? = .nonnull, toConvertTo expected: String, file: String = #file, line: Int = #line) {
        let converted = typeMapperConvert(type, nullability: nullability)
        
        if converted != expected {
            recordFailure(withDescription: "Expected type \(type) to convert into '\(expected)', but received '\(converted)' instead.",
                inFile: file, atLine: line, expected: false)
        }
    }
    
    private func typeMapperConvert(_ type: ObjcType, nullability: TypeNullability?) -> String {
        let context = TypeContext()
        let mapper = TypeMapper(context: context)
        
        var ctx: TypeMapper.TypeMappingContext = .empty
        if let nul = nullability {
            ctx = TypeMapper.TypeMappingContext(explicitNullability: nul)
        }
        
        return mapper.swiftType(forObjcType: type, context: ctx)
    }
}
