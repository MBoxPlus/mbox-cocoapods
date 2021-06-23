//
//  Source.swift
//  MBoxCocoapods
//
//  Created by Whirlwind on 2019/7/27.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Cocoa
import MBoxCore
import MBoxGit

public class Source: NSObject {

    public convenience init?(url: String) {
        guard let u = MBGitURL(url) else { return nil }
        var domains = u.host.split(separator: ".")
        domains.removeLast()
        let domain = domains.removeLast()
        let name = domain + "-" + u.project
        let root = FileManager.home.appending(pathComponent: ".cocoapods/repos").appending(pathComponent: name)
        self.init(root: root, url: url)
    }

    public convenience init?(root: String) {
        let cdnURLFile = root.appending(pathComponent: ".url")
        let url: String?
        if cdnURLFile.isExists {
            url = try? String(contentsOfFile: cdnURLFile)
        } else {
            url = try? GitHelper(path: root).url
        }
        if let url = url {
            self.init(root: root, url: url)
        } else {
            return nil
        }
    }

    public init(root: String, url: String) {
        self.root = root
        self.url = url
    }

    public let root: String
    public let url: String
    public lazy var name: String = root.lastPathComponent

    public override var description: String {
        return url
    }

    lazy var metadataPath: String = root.appending(pathComponent: "CocoaPods-version.yml")
    lazy var metadata: Metadata = Metadata.load(fromFile: metadataPath) ?? Metadata()

    lazy var specsDir: String = {
        let subDir = root.appending(pathComponent: "Specs")
        if subDir.isDirectory {
            return subDir
        } else {
            return root
        }
    }()

    public func path(for name: String) -> String {
        let fragment = metadata.pathFragment(name: name)
        return root.appending(pathComponent: fragment.joined(separator: "/"))
    }

    public func path(for name: String, version: String) -> [String] {
        let dir = self.path(for: name)
        var v = version
        v = v.deleteSuffix(".1-binary")
        v = v.deleteSuffix(".1.binary")
        return [
            dir.appending(pathComponent: v),
            dir.appending(pathComponent: v + ".1-binary"),
            dir.appending(pathComponent: v + ".1.binary"),
        ]
    }

    public func specifationPath(for name: String, version: String) -> String? {
        for dir in path(for: name, version: version) {
            var path = dir.appending(pathComponent: "\(name).podspec.json")
            if path.isFile {
                return path
            }
            path = dir.appending(pathComponent: "\(name).podspec")
            if path.isFile {
                return path
            }
        }
        return nil
    }

    public class func specifationPath(name: String, sources: [Source]) throws -> String? {
        for source in sources {
            for version in source.allVersions(for: name) {
                if let spec = try specifationPath(name: name, version: version, sources: [source]) {
                    return spec
                }
            }
        }
        return nil
    }

    public class func specifationPath(name: String, version: String, sources: [Source]) throws -> String? {
        for source in sources {
            if !source.root.isDirectory {
                throw UserError("The cocoapods spec repo is not donloaded. Please run `mbox pod install` first.")
            }
            if let specPath = source.specifationPath(for: name, version: version) {
                UI.log(verbose: "Found the spec: \(specPath)")
                return specPath
            }
        }
        return nil
    }

    public func allVersions(for name: String) -> [String] {
        let dir = path(for: name)
        guard var versions = try? FileManager.default.contentsOfDirectory(atPath: dir) else {
            return []
        }
        versions = versions.filter { dir.appending(pathComponent: $0).isDirectory }
        versions = versions.sorted(by: {
            $0.compare($1, options: .numeric) == .orderedDescending
        })
        return versions
    }

    public static var homeDir: String {
        let env = ProcessInfo.processInfo.environment
        return (env["CP_HOME_DIR"] ?? "~/.cocoapods").expandingTildeInPath
    }

    public static var dir: String {
        let env = ProcessInfo.processInfo.environment
        return env["CP_REPOS_DIR"]?.expandingTildeInPath ?? homeDir.appending(pathComponent: "repos")
    }

    public static var all: [Source] {
        if !dir.isDirectory { return [] }
        let filenames = try? FileManager.default.contentsOfDirectory(atPath: dir)
        return filenames?.compactMap { Source(root: dir.appending(pathComponent: $0)) } ?? []
    }
}
