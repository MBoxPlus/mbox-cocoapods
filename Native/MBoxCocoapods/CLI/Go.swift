//
//  Go.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/24.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore

extension MBWorkspace {
    @_dynamicReplacement(for: workspacePaths)
    open var cocoapods_workspacePaths: [String: String] {
        var paths = self.workspacePaths
        for path in [xcworkspacePath, xcodeprojPath] {
            if path.isExists {
                let name = path.relativePath(from: self.rootPath)
                paths[name] = ""
                break
            }
        }
        return paths
    }

}
