//
//  MBWorkRepo+Container.swift
//  MBoxCocoapods
//
//  Created by Yao Li on 2020/8/11.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxContainer
import MBoxDependencyManager

extension MBWorkRepo {

    @_dynamicReplacement(for: fetchContainers())
    public func cocoapods_fetchContainers() -> [MBWorkRepo.Container] {
        var value = self.fetchContainers()
        for (name, path) in self.podfilePaths {
            let container = Container(name: name, tool: .CocoaPods, repo: self)
                .withSpec(path: path)
            if let lockPath = self.podlock(for: path) {
                container.withLock(path: lockPath)
            }
            value.append(container)
        }
        return value
    }

}
