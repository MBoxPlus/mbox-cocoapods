//
//  MBWorkRepo+Container.swift
//  MBoxCocoapods
//
//  Created by Yao Li on 2020/8/11.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore
import MBoxContainer
import MBoxDependencyManager

extension MBWorkRepo {

    @_dynamicReplacement(for: fetchContainers())
    open func cocoapods_fetchContainers() -> [MBContainer] {
        var value = self.fetchContainers()
        if let setting = self.setting.cocoapods,
           setting.podfile != nil,
           setting.xcodeproj != nil {
            value.append(MBContainer(name: self.name, tool: .CocoaPods))
        }
        return value
    }

}
