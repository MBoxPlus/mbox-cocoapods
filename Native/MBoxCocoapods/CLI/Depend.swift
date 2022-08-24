//
//  Depend.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2021/8/3.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxRuby
import MBoxDependencyManager

extension MBCommander.Depend {
    public func fetchCocoaPodsDependencies(_ names: [String]) throws -> [String: Any] {
        let pod = PodCMD()
        return try pod.getDependencyInfo(withNames: names).toCodableObject() as? [String : Any] ?? [:]
    }

    @_dynamicReplacement(for: showAllDependencies(_:for:))
    public func cocoapods_showAllDependencies(_ names: [String], for tool: MBDependencyTool) throws -> [String: Any] {
        if tool == .CocoaPods {
            return try self.fetchCocoaPodsDependencies(names)
        }
        return try self.showAllDependencies(names, for: tool)
    }
}
