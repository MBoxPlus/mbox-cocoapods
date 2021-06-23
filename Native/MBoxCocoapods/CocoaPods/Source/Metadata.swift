//
//  Metadata.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/27.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

class Metadata: MBCodableObject, MBYAMLProtocol {

    @Codable(key: "min")
    var minVersion: String?

    @Codable(key: "max")
    var maxVersion: String?

    @Codable(key: "last")
    var latestVersion: String?

    @Codable(key: "prefix_lengths")
    var prefixLengths: [Int]?

    public func pathFragment(name: String, version: String? = nil) -> [String] {
        var prefixes: [String]
        if let lengths = prefixLengths,
            lengths.count > 0,
            var hashed = name.hashed(.md5) {
            prefixes = lengths.map { length in
                let v = hashed[..<length]
                hashed.removeFirst(length)
                return String(v)
            }
            prefixes.insert("Specs", at: 0)
        } else {
            prefixes = []
        }
        prefixes << name
        if let version = version {
            prefixes << version
        }
        return prefixes
    }
}
