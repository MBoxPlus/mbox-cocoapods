//
//  Pod.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/22.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxRuby
import MBoxKerberos

extension MBCommander {
    open class Pod: Bundle {

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
            try super.run()
        }
    }
}
