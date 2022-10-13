//
//  Switch.swift
//  MBoxCocoapods
//
//  Created by cppluwang on 2020/9/10.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxContainer

extension MBCommander.Container.Switch {
    @_dynamicReplacement(for: run())
    public func containerRun() throws {
        try self.run()

        if self.workspace.podShouldInstall {
            UI.log(warn: "The sandbox is not in sync with the Podfile.lock. You may need to run 'mbox pod install'.")
        }
    }
}
