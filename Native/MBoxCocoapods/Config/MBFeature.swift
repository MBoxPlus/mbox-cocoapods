//
//  MBConfig.Feature.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/24.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxContainer
import MBoxDependencyManager

extension MBConfig.Feature {
    @_dynamicReplacement(for: supportFiles)
    public var cocoaPodsSupportFiles: [String] {
        var files = supportFiles + ["Podfile", "Podfile.lock"]
        if let xcworkspace = cocoaPodsXcworkspaceFile {
            files.append(xcworkspace)
        }
        return files
    }
    
    @_dynamicReplacement(for: allContainerFiles(platformTool:))
    public func cocoaPodsContainerFiles(platformTool: MBDependencyTool) ->[String] {
        var files = allContainerFiles(platformTool: platformTool)
        if platformTool != .CocoaPods {
            return files
        }

        files += ["Podfile", "Podfile.lock"]
        if let xcworkspace = cocoaPodsXcworkspaceFile {
            files.append(xcworkspace)
        }
        return files
    }
    
    var cocoaPodsXcworkspaceFile: String? {
        if let xcworkspace = try? FileManager.default.contentsOfDirectory(atPath: Workspace.rootPath).first(where: { $0.pathExtension.lowercased() == "xcworkspace"
        }) {
            return xcworkspace
        }
        return nil
    }

    @_dynamicReplacement(for: syncContainerTools)
    public class var cocoapods_syncContainerTools: [[MBDependencyTool]] {
        var tools = self.syncContainerTools
        tools.append([.CocoaPods, .Bundler])
        return tools
    }

}
