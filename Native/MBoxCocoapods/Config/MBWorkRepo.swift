//
//  MBWorkRepo.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/24.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxContainer
import MBoxDependencyManager

extension MBWorkRepo {

    public static var podfileNames: [String] = [
        "CocoaPods.podfile.yaml",
        "CocoaPods.podfile",
        "Podfile",
        "Podfile.rb"
    ]

    public var podfilePaths: [String: String] {
        var podfiles = self.setting.cocoapods?.podfiles ?? [:]
        if let podfile = self.setting.cocoapods?.podfile {
            podfiles[self.name] = podfile
        }
        return self.paths(for: podfiles, defaults: (self.name, Self.podfileNames))
    }

    public func podlock(for path: String) -> String? {
        let path = path.deletingLastPathComponent.appending(pathComponent: "Podfile.lock")
        return path.isFile ? path : nil
    }

    public var podspecPaths: [String] {
        var specs = self.setting.cocoapods?.podspecs ?? []
        if specs.isEmpty, let spec = self.setting.cocoapods?.podspec {
            specs.append(spec)
        }
        return self.paths(for: specs, defaults: ["*.podspec{.json,}"])
    }

    @_dynamicReplacement(for: resolveComponents())
    public func cocoapods_resolveComponents() -> [Component] {
        var names = self.resolveComponents()
        let data = self.podspecPaths.map {
            Component(name: $0.lastPathComponent.deleteSuffix(".json").deleteSuffix(".podspec"),
                      tool: MBDependencyTool.CocoaPods,
                      repo: self)
        }
        names.append(contentsOf: data)
        return names
    }
}

extension MBWorkRepo {
    @_dynamicReplacement(for: pathsToLink)
    public var cocoapods_pathsToLink: [String] {
        var paths = self.pathsToLink
        if !self.model.activatedContainers(for: .CocoaPods).isEmpty,
           let config = self.setting.cocoapods?.symlinks {
            paths.append(contentsOf: config)
        }
        return paths
    }
}
