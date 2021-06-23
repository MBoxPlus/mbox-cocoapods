//
//  MBFeature+Container.swift
//  MBoxCocoapods
//
//  Created by cppluwang on 2020/8/21.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore
import MBoxContainer
import MBoxDependencyManager

extension MBConfig.Feature {
    @_dynamicReplacement(for: clearWorkspaceEnv(platformTool:))
    open func cocoapods_clearWorkspaceEnv(platformTool: MBDependencyTool) throws {
        if platformTool == .CocoaPods {
            if (FileManager.default.fileExists(atPath: Workspace.podlockPath)) {
                try FileManager.default.removeItem(atPath: Workspace.podlockPath)
            }

            if (FileManager.default.fileExists(atPath: Workspace.xcworkspacePath)) {
                try FileManager.default.removeItem(atPath: Workspace.xcworkspacePath)
            }

            if (FileManager.default.fileExists(atPath: Workspace.podSandboxPath)) {
                try FileManager.default.removeItem(atPath: Workspace.podSandboxPath)
            }
        }
        try clearWorkspaceEnv(platformTool:platformTool)
    }
}
