//
//  MBSetting.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/11/18.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore

extension MBSetting.Workspace {
    @objc public var integrate: Bool {
        set {
            self.dictionary["integrate"] = newValue
        }
        get {
            return (self.dictionary["integrate"] as? Bool) ?? false
        }
    }
}

extension MBSetting {
    
    public class Cocoapods: MBCodableObject {
        @Codable
        public var xcodeproj: String?

        @Codable
        public var podfile: String?

        @Codable
        public var lockfile: String?
        
        @Codable
        public var podspec: String?
        
        @Codable
        public var podspecs: [String]?

        @Codable
        public var symlinks: [String]?
    }

    public var cocoapods: Cocoapods? {
        set {
            self.dictionary["cocoapods"] = newValue
        }
        get {
            if let v: Cocoapods = self.value(forPath: "cocoapods") {
                return v
            }
            var hash = [String: Any]()
            for name in ["xcodeproj", "podfile", "lockfile", "podspec", "podspecs"] {
                if let value = self.dictionary[name] as? String {
                    hash[name] = value
                } else if let arrayValue = self.dictionary[name] as? [String] {
                    hash[name] = arrayValue
                }
            }
            if hash.isEmpty { return nil }
            let v = Cocoapods(dictionary: hash)
            self.dictionary["cocoapods"] = v
            return v
        }
    }


}
