//
//  UserDependency.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2020/1/8.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBDependencyTool {
    public static let CocoaPods = MBDependencyTool("CocoaPods")

    @_dynamicReplacement(for: allTools)
    public static var cocoapods_allTools: [MBDependencyTool] {
        var tools = self.allTools
        tools.insert(.CocoaPods, at: 0)
        return tools
    }
}
