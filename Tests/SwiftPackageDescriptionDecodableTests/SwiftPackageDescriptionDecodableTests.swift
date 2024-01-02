import XCTest
@testable import SwiftPackageDescriptionDecodable

final class SwiftPackageDescriptionDecodableTests: XCTestCase {
    func testThatWeCanDecodeThisPackagesDescription() throws {
        let description = 
"""
{
  "dependencies" : [

  ],
  "manifest_display_name" : "SwiftPackageDescription",
  "name" : "SwiftPackageDescription",
  "path" : "/Users/nicolas.richard/Projects/SwiftPackageDescription",
  "platforms" : [

  ],
  "products" : [
    {
      "name" : "SwiftPackageDescription",
      "targets" : [
        "SwiftPackageDescription"
      ],
      "type" : {
        "library" : [
          "automatic"
        ]
      }
    }
  ],
  "targets" : [
    {
      "c99name" : "SwiftPackageDescriptionTests",
      "module_type" : "SwiftTarget",
      "name" : "SwiftPackageDescriptionTests",
      "path" : "Tests/SwiftPackageDescriptionTests",
      "sources" : [
        "SwiftPackageDescriptionTests.swift"
      ],
      "target_dependencies" : [
        "SwiftPackageDescription"
      ],
      "type" : "test"
    },
    {
      "c99name" : "SwiftPackageDescription",
      "module_type" : "SwiftTarget",
      "name" : "SwiftPackageDescription",
      "path" : "Sources/SwiftPackageDescription",
      "product_memberships" : [
        "SwiftPackageDescription"
      ],
      "sources" : [
        "DescribedPackage.swift"
      ],
      "type" : "library"
    }
  ],
  "tools_version" : "5.9"
}
"""
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = description.data(using: .utf8) else {
            XCTFail("Could not convert description to data")
            return
        }
        
        let package = try decoder.decode(DescribedPackage.self, from: data)
        
        XCTAssertEqual(package.name, "SwiftPackageDescription")
        XCTAssertEqual(package.path, "/Users/nicolas.richard/Projects/SwiftPackageDescription")
        XCTAssertEqual(package.dependencies.count, 0)
        XCTAssertEqual(package.platforms.count, 0)
        XCTAssertEqual(package.products.count, 1)
        XCTAssertEqual(package.targets.count, 2)
    }
}
