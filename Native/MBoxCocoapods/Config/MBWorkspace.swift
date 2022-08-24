//
//  MBWorkspace.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/24.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxRuby
import MBoxGit
import MBoxDependencyManager

var MBWorkspacePodSearchEngineFlag: UInt8 = 0
var MBWorkspacePodDependencyInfoFlag: UInt8 = 0

extension MBWorkspace {

    public var podSearchEngine: MBPodSearchEngine {
        return associatedObject(base: self, key: &MBWorkspacePodSearchEngineFlag) {
            return MBPodSearchEngine(workspace: self)
        }
    }

    @_dynamicReplacement(for: setupSearchEngines())
    public func pod_setupSearchEngines() -> [MBDependencySearchEngine] {
        var engines = self.setupSearchEngines()
        engines.append(self.podSearchEngine)
        return engines
    }

    public var xcworkspacePath: String {
        if let filename = try? FileManager.default.contentsOfDirectory(atPath: self.rootPath).first(where: { $0.ends(with: ".xcworkspace", caseSensitive: false) }) {
            return self.rootPath.appending(pathComponent: filename)
        }
        return self.rootPath.appending(pathComponent: self.rootPath.lastPathComponent.appending(pathExtension: "xcworkspace"))
    }

    public var xcodeprojPath: String {
        if let filename = try? FileManager.default.contentsOfDirectory(atPath: self.rootPath).first(where: { $0.ends(with: ".xcodeproj", caseSensitive: false) }) {
            return self.rootPath.appending(pathComponent: filename)
        }
        return self.rootPath.appending(pathComponent: self.rootPath.lastPathComponent.appending(pathExtension: "xcodeproj"))
    }

    public var podfilePath: String {
        return self.rootPath.appending(pathComponent: "Podfile")
    }

    public var podlockPath: String {
        return self.rootPath.appending(pathComponent: "Podfile.lock")
    }

    public var podSandboxPath: String {
        return self.rootPath.appending(pathComponent: "Pods")
    }
    
    public var podProjectPath: String {
        return self.podSandboxPath.appending(pathComponent: "Pods.xcodeproj")
    }

    public var podManifestPath: String {
        return self.podSandboxPath.appending(pathComponent: "Manifest.lock")
    }

    dynamic
    public var podShouldInstall: Bool {
        if !self.podlockPath.isExists || !self.podManifestPath.isExists {
            return true
        }
        let path1 = self.podlockPath.destinationOfSymlink ?? self.podlockPath
        let path2 = self.podManifestPath.destinationOfSymlink ?? self.podManifestPath
        return !FileManager.default.contentsEqual(atPath: path1, andPath: path2)
    }
}
