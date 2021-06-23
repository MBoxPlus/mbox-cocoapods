//
//  Specification.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/27.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Cocoa
import MBoxCore
import MBoxDependencyManager

public class Specification: MBCodableObject, MBJSONProtocol {
    @Codable
    public var name: String

    @Codable
    public var version: String

    @Codable
    public var sourceCode: Dependency?

    @Codable
    public var source: Dependency?

    public override func prepare(dictionary: [String : Any]) -> [String : Any] {
        var dictionary = super.prepare(dictionary: dictionary)
        if let sourceCode = dictionary.removeValue(forKey: "source_code") {
            dictionary["source_code"] = try? Dependency.load(fromObject: sourceCode)
        }
        if let source = dictionary.removeValue(forKey: "source") {
            dictionary["source"] = try? Dependency.load(fromObject: source)
        }
        return dictionary
    }
    
    open class func load(from path: String) throws -> Specification {
        let content: String
        if path.pathExtension == "json" {
            content = try String(contentsOfFile: path)
        } else {
            // TTY 模式不支持 error 通道，为了避免 Error 通道的信息干扰，不使用 TTY
            guard let rootPath = UI.workspace?.rootPath else {
                throw RuntimeError("Convert podspec to json must run in workspace.")
            }
            let pod = PodCMD(workingDirectory: rootPath, useTTY: false)
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
