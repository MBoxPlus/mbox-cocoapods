//
//  Status.swift
//  MBoxCocoapods
//
//  Created by cppluwang on 2020/9/10.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore

extension MBCommander.Feature.Start {
    @_dynamicReplacement(for: run())
    open func featureRun() throws {
        try self.run()
        
        if self.workspace.podShouldInstall {
            UI.log(warn: "The sandbox is not in sync with the Podfile.lock. You may need to run 'mbox pod install'.")
        } else {
            UI.log(warn: "The sandbox is in sync，no need to run 'mbox pod install'")
        }
    }
}
