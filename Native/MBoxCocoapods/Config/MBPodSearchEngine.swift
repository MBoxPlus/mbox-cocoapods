//
//  MBPodSearchEngine.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2020/4/15.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxGit
import MBoxDependencyManager
import MBoxRuby

open class MBPodSearchEngine: MBDependencySearchEngine {
    public var engineName: String = "CocoaPods"

    public var enginePriority: Int = 50

    public var url: MBGitURL?

    dynamic
    public func allDependencies() throws -> [Dependency] {
        return []
    }

    dynamic
    public func searchDependencies(by names: [String]) throws -> [Dependency] {
        let dependencies: [String: Dependency] = try UI.log(verbose: "Get all dependencies:") {
            let pod = PodCMD(workingDirectory: self.workspace.rootPath)
            return try pod.getDependencyInfo(detailed: true)
        }
        let dependenciesByGit = Dictionary(grouping: dependencies.values) { $0.git?.lowercased() ?? ""
        }
        let foundDependencies = names.compactMap { dependencies[$0.lowercased()] }
        guard let git = foundDependencies.compactMap({ $0.git }).first,
              let otherDps = dependenciesByGit[git.lowercased()] else {
            return foundDependencies
        }
        return (foundDependencies + otherDps).withoutDuplicates()
    }

    public func resolveDependency(name: String, version: String, source: String?) throws -> Dependency? {
        let cmd = PodCMD()
        let spec = try cmd.getSpecification(name: name, version: version, source: source)
        return try self.dependency(for: spec)
    }

    public func resolveDependency(name: String, version: String?) throws -> Dependency? {
        let cmd = PodCMD()
        let spec = try cmd.getSpecification(name: name, version: version, source: nil)
        let dep = try dependency(for: spec)
        if version == nil {
            dep.gitPointer = nil
            dep.version = nil
        }
        UI.log(verbose: "Use \(dep)")
        return dep
    }

    init(workspace: MBWorkspace) {
        self.workspace = workspace
    }
    open weak var workspace: MBWorkspace!

    public func dependency(for specPath: String) throws -> Dependency {
        let spec = try specification(path: specPath)
        return try self.dependency(for: spec)
    }

    public func dependency(for spec: Specification) throws -> Dependency {
        guard let sourceCode = (spec.sourceCode ?? spec.source) else {
            throw RuntimeError("Could not find sourcecode in the spec: `\(spec.filePath!)`")
        }
        guard let url = sourceCode.git else {
            throw RuntimeError("Source type is not supported!")
        }
        let dep = Dependency()
        dep.name = spec.name
        dep.version = spec.version
        dep.git = url
        dep.gitPointer = sourceCode.gitPointer
        return dep
    }

    open func specification(path: String) throws -> Specification {
        let content: String
        if path.pathExtension == "json" {
            content = try String(contentsOfFile: path)
        } else {
            let pod = PodCMD(workingDirectory: self.workspace.rootPath, useTTY: false)
            guard pod.exec("ipc spec '\(path)'") else {
                throw RuntimeError("Convert podspec to json failed: `\(path)`")
            }
            content = pod.outputString
        }
        var spec = try Specification.load(fromString: content, coder: .json)
        spec.filePath = path
        return spec
    }

}
