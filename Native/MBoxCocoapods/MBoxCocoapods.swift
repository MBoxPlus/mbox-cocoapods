//
//  MBoxCocoapods.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/22.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Cocoa
import MBoxCore
import MBoxWorkspaceCore

@objc(MBoxCocoapods)
open class MBoxCocoapods: NSObject, MBPluginProtocol {

    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.Pod.self)
    }
}
