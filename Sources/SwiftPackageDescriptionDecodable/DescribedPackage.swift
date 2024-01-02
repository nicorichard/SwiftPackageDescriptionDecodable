import Foundation

public struct DescribedPackage: Decodable {
    public let name: String
    public let manifestDisplayName: String
    public let path: String
    public let toolsVersion: String
    public let dependencies: [DescribedPackageDependency]
    public let defaultLocalization: String?
    public let platforms: [DescribedPlatformRestriction]
    public let products: [DescribedProduct]
    public let targets: [DescribedTarget]
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    public let swiftLanguagesVersions: [String]?
    
    public struct DescribedPlatformRestriction: Decodable {
        public let name: String
        public let version: String
        public let options: [String]?
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
        public let name: String
        public let type: ProductType
        public let targets: [String]
        
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
        public let type: String
        public let intent: CommandIntent?
        public let permissions: [Permission]?
        
        public struct CommandIntent: Decodable {
            public let type: String
            public let verb: String?
            public let description: String?
        }

        public struct Permission: Decodable {
            public enum NetworkScope: Decodable {
                case none
                case local(ports: [Int])
                case all(ports: [Int])
                case docker
                case unixDomainSocket
            }

            public let type: String
            public let reason: String
            public let networkScope: NetworkScope
        }
    }

    public struct DescribedTarget: Decodable {
        public let name: String
        public let type: String
        public let c99name: String?
        public let moduleType: String?
        public let pluginCapability: DescribedPluginCapability?
        public let path: String
        public let sources: [String]
        public let resources: [DescribedResource]?
        public let targetDependencies: [String]?
        public let productDependencies: [String]?
        public let productMemberships: [String]?
    }
    
    public struct DescribedResource: Decodable, Equatable {
        public let rule: Rule
        public let path: String

        public enum Rule: Decodable, Equatable {
            case process(localization: String?)
            case copy
            case embedInCode
        }
    }
}

public struct DescribedRange<T: Decodable>: Decodable {
    public let lowerBound: T
    public let upperBound: T
}

extension DescribedRange: Sendable where T: Sendable {}
extension DescribedRange: Equatable where T: Equatable {}
