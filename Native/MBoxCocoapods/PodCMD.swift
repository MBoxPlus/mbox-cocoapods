//
//  PodCMD.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/8/24.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxRuby
import MBoxWorkspaceCore

extension MBCommander.Exec {
    @_dynamicReplacement(for: setupCMDMap())
    open func pod_setupCMDMap() -> [String: MBCMD.Type] {
        var map = self.setupCMDMap()
        map["pod"] = PodCMD.self
        return map
    }
}

open class PodCMD: BundlerCMD {
    public required init(useTTY: Bool? = nil) {
        super.init(useTTY: useTTY)
        self.bin = "\(self.bin) exec pod"
    }

    dynamic
    open override func setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        return super.setupEnvironment(base)
    }

    open override func exec(_ string: String, workingDirectory: String? = nil, env: [String : String]? = nil) -> Int32 {
        var string = string
        string.append(" --ansi")
        if UI.verbose {
            string.append(" --verbose")
        }
        return super.exec(string, workingDirectory: workingDirectory, env: env)
    }
    
    dynamic
    open func getDependencyInfo(withName name: String) throws -> MBWorkspace.PodDependencyInfo {
        return try self.getDependencyInfo(withNames: [name])
    }

    open func getDependencyInfo(withNames names: [String]) throws -> MBWorkspace.PodDependencyInfo {
        let tmp = FileManager.temporaryPath("pod_dependencies.json")
        if tmp.isExists {
            try FileManager.default.removeItem(atPath: tmp)
        }
        guard self.exec("mbox dependencies \(names.map { $0.quoted }.joined(separator: " ")) --output-file=\(tmp.quoted)") else {
            throw RuntimeError("Query dependency \(names.map { "`\($0.quoted)`" }.joined(separator: ", ")) failed.")
        }
        let string = try String(contentsOfFile: tmp)
        let dependencyInfo = try MBWorkspace.PodDependencyInfo.load(fromString: string, coder: .json)
        return dependencyInfo
    }
}

