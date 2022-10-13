//
//  Pod.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/22.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxContainer
import MBoxRuby

extension MBCommander {
    open class Pod: Bundle {
        open class override var description: String? {
            return "Redirect to CocoaPods with MBox environment"
        }

        dynamic
        open override var cmd: MBCMD {
            let cmd = PodCMD()
            cmd.showOutput = true
            return cmd
        }

        open override func validate() throws {
            try self.validateMultipleContainers(for: .CocoaPods)
            try super.validate()
        }

        dynamic
        open override func run() throws {
            try UI.log(verbose: "Ignore Pods Sandbox") {
                try self.gitIgnoreSandbox()
            }
            try super.run()
        }

        dynamic
        open var gitIgnoreRules: [String] {
            return ["Pods"]
        }

        open func gitIgnoreSandbox() throws {
            for container in self.config.currentFeature.activatedContainers(for: .CocoaPods) {
                guard let repo = container.repo else { continue }
                guard let git = repo.git else { continue }
                guard let path = git.untrackedIgnoreConfigPath else { continue }
                var uninstalledRules = gitIgnoreRules
                uninstalledRules.removeAll(git.ignoreRules(from: path))
                if uninstalledRules.isEmpty {
//                    UI.log(verbose: "[\(repo)] Git ignore injected, skip.")
                    continue
                }
                UI.log(verbose: "[\(repo)] Git ignore \(uninstalledRules.map { "`\($0)`" }.joined(separator: ", "))") {
                    do {
                        try git.ignore(rules: uninstalledRules, configPath: path)
                    } catch {
                        UI.log(verbose: error.localizedDescription)
                    }
                }
            }
        }
    }
}
