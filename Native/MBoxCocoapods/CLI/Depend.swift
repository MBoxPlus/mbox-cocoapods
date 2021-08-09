//
//  Depend.swift
//  MBoxCocoapods
//
//  Created by 詹迟晶 on 2021/8/3.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxRuby
import MBoxDependencyManager

extension MBCommander.Depend {
    open func fetchCocoaPodsDependencies() throws -> [String: Any] {
        try UI.log(verbose: "Check bundler environment") {
            try BundlerCMD.setup(workingDirectory: self.workspace.rootPath)
        }
        let pod = PodCMD()
        return try pod.getDependencyInfo(withNames: []).toCodableObject() as? [String : Any] ?? [:]
    }

    @_dynamicReplacement(for: showAllDependencies(for:))
    open func cocoapods_showAllDependencies(for tool: MBDependencyTool) throws -> [String: Any] {
        if tool == .CocoaPods {
            return try self.fetchCocoaPodsDependencies()
        }
        return try self.showAllDependencies(for: tool)
    }
}
