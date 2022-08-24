//
//  PodCMD.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/18.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxContainer

extension PodCMD {
    @_dynamicReplacement(for: setupEnvironment(_:))
    public func container_pod_setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        let env = self.setupEnvironment(base)

        var containerEnvs: [String: String] = [:]
        let currentFeature = workspace.config.currentFeature
        let containerRepos = currentFeature.containers(for: .CocoaPods).map(\.name)
        containerEnvs["MBOX_CONTAINER_REPOS"] = containerRepos.toJSONString(pretty: false)!
        let currentContainer = currentFeature.activatedContainers(for: .CocoaPods).first
        containerEnvs["MBOX_CURRENT_CONTAINER"] = currentContainer?.name
        containerEnvs["MBOX_CURRENT_CONTAINER_PATH"] = currentContainer?.path

        return env.merging(containerEnvs, uniquingKeysWith: { $1 })
    }
}
