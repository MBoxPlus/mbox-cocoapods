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
import MBoxWorkspaceCore
import MBoxDependencyManager
import MBoxRuby

open class MBPodSearchEngine: MBDependencySearchEngine {
    public var engineName: String = "CocoaPods"

    public var enginePriority: Int = 50

    dynamic
    open func getCurrentDependency(by names: [String]) throws -> Dependency? {
        try UI.log(verbose: "Check bundler environment") {
            try BundlerCMD.setup(workingDirectory: self.workspace.rootPath)
        }
        let pod = PodCMD(workingDirectory: self.workspace.rootPath)
        let info = try pod.getDependencyInfo(withNames: names)
        if let sources = info.sources {
            self.sources = sources
        }
        if let value = info.dependencies?.first {
            let (name, dependency) = value
            if let source = info.source(for: dependency) {
                self.sources = [source]
            }
            dependency.name = name
            return dependency
        }
        return nil
    }

    dynamic
    public func getCurrentDependenciesInSameRepo(by dependency: Dependency) -> [Dependency] {
        return []
    }

    public func resolveDependency(name: String, version: String?, url: String?) throws -> Dependency? {
        let dep = Dependency()
        if let version = version {
            let specPath: String = try UI.log(verbose: "Query podspec with \(name) (\(version)) in sources:", items: self.sources.map { $0.description }) {
                guard let specPath = try Source.specifationPath(name: name, version: version, sources: self.sources) else {
                    throw RuntimeError("Could not find the podspec `\(name) (\(version))`.\nThe cocoapods spec repo maybe outdated. Please try to run `mbox pod repo update` first.")
                }
                return specPath
            }
            let info = try source(for: specPath)
            dep.name = info.name
            dep.git = info.url
            dep.gitPointer = info.git
        } else {
            UI.log(verbose: "Could not find the dependency `\(name)` from CocoaPods Dependencies, MBox will search it from global environment.")
            let specPath: String = try UI.log(verbose: "Query lastest podspec with `\(name)` in sources:", items: self.sources.map({ $0.description })) {
                guard let specPath = try Source.specifationPath(name: name, sources: self.sources) else {
                    throw RuntimeError("Could not find the podspec `\(name)`.\nThe cocoapods spec repo maybe outdated. Please try to run `mbox pod repo update` first.")
                }
                return specPath
            }
            let info = try source(for: specPath)
            dep.name = info.name
            dep.git = info.url
        }
        return dep
    }

    init(workspace: MBWorkspace) {
        self.workspace = workspace
    }
    open weak var workspace: MBWorkspace!
    open lazy var sources: [Source] = Source.all

    public func source(for specPath: String) throws -> (name: String, url: String, git: GitPointer?) {
        let spec = try specification(path: specPath)
        guard let sourceCode = (spec.sourceCode ?? spec.source) else {
            throw RuntimeError("Could not find sourcecode in the spec: `\(spec.filePath!)`")
        }
        guard let url = sourceCode.git else {
            throw RuntimeError("Source type is not supported!")
        }
        UI.log(verbose: "Use \(spec.name): \(url) (\(sourceCode.gitPointer?.description ?? "none"))")
        return (name: spec.name, url: url, git: sourceCode.gitPointer)
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
