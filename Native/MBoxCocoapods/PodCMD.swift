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
import MBoxDependencyManager

extension MBCommander.Exec {
    @_dynamicReplacement(for: setupCMDMap())
    public func pod_setupCMDMap() -> [String: MBCMD.Type] {
        var map = self.setupCMDMap()
        map["pod"] = PodCMD.self
        return map
    }
}

open class PodCMD: BundlerCMD {
    public required init(useTTY: Bool? = nil) {
        super.init(useTTY: useTTY)
        self.args.append(contentsOf: ["exec", "pod"])
    }

    dynamic
    open override func setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        let env = super.setupEnvironment(base)

        let packageNames = workspace.config.currentFeature.workRepos.flatMap { $0.activatedComponents(for: .CocoaPods) }.map(\.name)
        let dps = workspace.config.currentFeature.dependencies.array.filter {
            ($0.mode == .local || $0.mode == .remote || $0.mode == .version) &&
                !packageNames.contains($0.name!)
        }.map { dp -> (String, [String: Any]) in
            var hash = dp.toCodableObject() as! [String: Any]
            let name = hash.removeValue(forKey: "name")! as! String
            return (name, hash)
        }
        if dps.isEmpty { return env }
        return env.merging(["MBOX_COCOAPODS_DEPENDENCIES": Dictionary(dps).toJSONString(pretty: false)!], uniquingKeysWith: { $1 })
    }

    open override func exec(_ string: String, workingDirectory: String? = nil, env: [String : String]? = nil) -> Int32 {
        var string = string
        string.append(" --ansi")
        if MBProcess.shared.verbose {
            string.append(" --verbose")
        }
        return super.exec(string, workingDirectory: workingDirectory, env: env)
    }

    open func getDependencyInfo(withNames names: [String] = [], detailed: Bool = false) throws -> [String: Dependency] {
        try BundlerCMD.setup(workingDirectory: self.workingDirectory)
        let tmp = FileManager.temporaryPath("pod_dependencies.json")
        if tmp.isExists {
            try FileManager.default.removeItem(atPath: tmp)
        }
        var command = "mbox dependencies \(names.map { $0.quoted }.joined(separator: " ")) --output-file=\(tmp.quoted)"
        if detailed {
            command += " --detailed"
        }
        guard self.exec(command) else {
            throw RuntimeError("Query dependency \(names.map { "`\($0.quoted)`" }.joined(separator: ", ")) failed.")
        }
        let string = try String(contentsOfFile: tmp)
        return try [String: Dependency].load(fromString: string, coder: .json)
    }

    open func getSpecification(name: String, version: String?, source: String?) throws -> Specification {
        try BundlerCMD.setup(workingDirectory: self.workingDirectory)
        let tmp = FileManager.temporaryPath("pod_specification.json")
        if tmp.isExists {
            try FileManager.default.removeItem(atPath: tmp)
        }
        var command = "mbox spec \(name) --output-file=\(tmp.quoted)"
        if let version = version {
            command += " --version=\(version)"
        }
        if let source = source {
            command += " --source=\(source)"
        }
        guard self.exec(command) else {
            throw RuntimeError("Query specification \(name) failed.")
        }
        return try Specification.load(from: tmp)
    }
}

