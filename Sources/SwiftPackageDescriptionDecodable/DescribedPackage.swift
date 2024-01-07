import Foundation

public struct DescribedPackage: Decodable {
    public var name: String
    public var manifestDisplayName: String
    public var path: String
    public var toolsVersion: String
    public var dependencies: [DescribedPackageDependency]
    public var defaultLocalization: String?
    public var platforms: [DescribedPlatformRestriction]
    public var products: [DescribedProduct]
    public var targets: [DescribedTarget]
    public var cLanguageStandard: String?
    public var cxxLanguageStandard: String?
    public var swiftLanguagesVersions: [String]?
    
    public struct DescribedPlatformRestriction: Decodable {
        public var name: String
        public var version: String
        public var options: [String]?
    }
    
    public enum DescribedRequirement: Decodable, Equatable, Sendable {
        case exact(String)
        case range(DescribedRange<String>)
        case revision(String)
        case branch(String)
        
        private enum CodingKeys: String, CodingKey {
            case exact, range, revision, branch
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            guard let key = container.allKeys.first(where: container.contains) else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Did not find a matching key"))
            }
            
            switch key {
            case .exact:
                var unkeyedValues = try container.nestedUnkeyedContainer(forKey: .exact)
                self = .exact(
                    try unkeyedValues.decode(String.self)
                )
            case .range:
                var unkeyedValues = try container.nestedUnkeyedContainer(forKey: .range)
                self = .range(
                    try unkeyedValues.decode(DescribedRange<String>.self)
                )
            case .revision:
                var unkeyedValues = try container.nestedUnkeyedContainer(forKey: .revision)
                self = .revision(
                    try unkeyedValues.decode(String.self)
                )
            case .branch:
                var unkeyedValues = try container.nestedUnkeyedContainer(forKey: .branch)
                self = .branch(
                    try unkeyedValues.decode(String.self)
                )
            }
        }
    }

    public enum DescribedPackageDependency: Decodable {
        case fileSystem(identity: String, path: String)
        case sourceControl(identity: String, location: String, requirement: DescribedRequirement)
        case registry(identity: String, requirement: DescribedRequirement)

        private enum CodingKeys: CodingKey {
            case type
            case path
            case url
            case requirement
            case identity
        }

        private enum Kind: String, Codable {
            case fileSystem
            case sourceControl
            case registry
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .type)
            let identity = try container.decode(String.self, forKey: .identity)
            switch kind {
            case .fileSystem:
                let path = try container.decode(String.self, forKey: .path)
                self = .fileSystem(identity: identity, path: path)
            case .sourceControl:
                let location = try container.decode(String.self, forKey: .url)
                let requirement = try container.decode(DescribedRequirement.self, forKey: .requirement)
                self = .sourceControl(identity: identity, location: location, requirement: requirement)
            case .registry:
                let requirement = try container.decode(DescribedRequirement.self, forKey: .requirement)
                self = .registry(identity: identity, requirement: requirement)
            }
        }
    }

    public struct DescribedProduct: Decodable {
        public var name: String
        public var type: ProductType
        public var targets: [String]
        
        public enum ProductType: Decodable {
            public enum LibraryType: String, Decodable {
                case `static`
                case `dynamic`
                case automatic
            }
            
            case library(LibraryType)
            case executable
            case snippet
            case plugin
            case test
            case `macro`
            
            private enum CodingKeys: String, CodingKey {
                case library, executable, snippet, plugin, test, `macro`
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                guard let key = container.allKeys.first(where: container.contains) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Did not find a matching key"))
                }
                switch key {
                case .library:
                    var unkeyedValues = try container.nestedUnkeyedContainer(forKey: key)
                    self = .library(
                        try unkeyedValues.decode(ProductType.LibraryType.self)
                    )
                case .test:
                    self = .test
                case .executable:
                    self = .executable
                case .snippet:
                    self = .snippet
                case .plugin:
                    self = .plugin
                case .macro:
                    self = .macro
                }
            }
        }
    }

    public struct DescribedPluginCapability: Decodable {
        public var type: String
        public var intent: CommandIntent?
        public var permissions: [Permission]?
        
        public struct CommandIntent: Decodable {
            public var type: String
            public var verb: String?
            public var description: String?
        }

        public struct Permission: Decodable {
            public enum NetworkScope: Decodable {
                case none
                case local(ports: [Int])
                case all(ports: [Int])
                case docker
                case unixDomainSocket
            }

            public var type: String
            public var reason: String
            public var networkScope: NetworkScope
        }
    }

    public struct DescribedTarget: Decodable {
        public var name: String
        public var type: String
        public var c99name: String?
        public var moduleType: String?
        public var pluginCapability: DescribedPluginCapability?
        public var path: String
        public var sources: [String]
        public var resources: [DescribedResource]?
        public var targetDependencies: [String]?
        public var productDependencies: [String]?
        public var productMemberships: [String]?
    }
    
    public struct DescribedResource: Decodable, Equatable {
        public var rule: Rule
        public var path: String

        public enum Rule: Decodable, Equatable {
            case process(localization: String?)
            case copy
            case embedInCode
        }
    }
}

public struct DescribedRange<T: Decodable>: Decodable {
    public var lowerBound: T
    public var upperBound: T
}

extension DescribedRange: Sendable where T: Sendable {}
extension DescribedRange: Equatable where T: Equatable {}
