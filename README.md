# SwiftPackageDescriptionDecodable

Provides a decodable representation for the [DescribedPackage](https://github.com/apple/swift-package-manager/blob/main/Sources/Commands/Utilities/DescribedPackage.swift) encoded json representation.

> 🚨 The package description returned by Swift Package Manager makes no claims about stability. Future Swift updates will undoubtedly require updates to this package as well.

## Usage

This decodable can be used to parse the output of the command

```shell
swift package describe --type json
```

by instantiating a `JSONDecoder` using the `.convertFromSnakeCase` key decoding strategy.

```swift
import Foundation
import SwiftPackageDescriptionDecodable

func decode(json: Data) -> DescribedPackage {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(DescribedPackage.self, from: json)
}
```