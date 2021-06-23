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

        open class override var description: String? {
            return "Redirect to CocoaPods with MBox environment"
        }

        open override class func autocompletion(argv: ArgumentParser) -> [String] {
            return [self.autocompletionRedirect]
        }

        dynamic
        open override var cmd: MBCMD {
            let cmd = PodCMD()
            cmd.showOutput = true
            if let name = kerberosName {
                cmd.env["MBOX_KERBEROS"] = name
            }
            return cmd
        }

        open var kerberosName: String?
        open override func run() throws {
            UI.log(verbose: "Renew kerberos ticket") {
                let listCMD = KListCMD()
                guard let info = listCMD.get() else {
                    UI.log(verbose: "No valid ticket, use `mbox kerberos init` to re-init.")
                    return
                }
                let email = info.principal
                var renewable = info.renewable
                if !renewable, let email = email {
                    let user = KInitCMD.convertEmail(email)
                    let securityCMD = SecurityCMD(account: user[0], service: user[1])
                    if securityCMD.hasGenericPassword() == 0 {
                        renewable = true
                    }
                }
                if renewable {
                    let kinit = KInitCMD()
                    if kinit.renew(email) == 0 {
                        self.kerberosName = email
                    }
                }
                if self.kerberosName == nil {
                    UI.log(verbose: "Could not auto renew ticket, use `mbox kerberos init` to re-init.")
                }
            }
            try super.run()
        }
    }
}
