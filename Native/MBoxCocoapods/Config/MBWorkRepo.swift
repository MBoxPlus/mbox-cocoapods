//
//  MBWorkRepo.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/24.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxWorkspaceCore
import MBoxContainer
import MBoxDependencyManager

extension MBWorkRepo {
    public func allPodspecPaths() -> [String] {
        var baseNames = self.setting.cocoapods?.podspecs ?? []
        if baseNames.isEmpty,
            let basename = self.setting.cocoapods?.podspec {
            baseNames = [basename]
        }
        if baseNames.isEmpty {
            for file in self.path.subFiles {
                let filePath = file.lastPathComponent
                if filePath.lowercased().hasSuffix(".podspec") || filePath.lowercased().hasSuffix(".podspec.json") {
                    baseNames.append(filePath)
                }
            }
        }
        return baseNames.compactMap {
            self.path.appending(pathComponent: $0)
        }.filter { $0.isExists }
    }

    @_dynamicReplacement(for: resolveDependencyNames())
    open func cocoapods_resolveDependencyNames() -> [(tool: MBDependencyTool, name: String)] {
        var names = self.resolveDependencyNames()
        let data = self.allPodspecPaths().map {
            (
                tool: MBDependencyTool.CocoaPods,
                name: $0.lastPathComponent.deleteSuffix(".json").deleteSuffix(".podspec")
            )
        }
        names.append(contentsOf: data)
        return names
    }
}

extension MBWorkRepo {
    @_dynamicReplacement(for: pathsToLink)
    open var cocoapods_pathsToLink: [String] {
        var paths = self.pathsToLink
        if !self.model.activatedContainers(for: .CocoaPods).isEmpty,
           let config = self.setting.cocoapods?.symlinks {
            paths.append(contentsOf: config)
        }
        return paths
    }
}
