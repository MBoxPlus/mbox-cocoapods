# Cocoapods for MBox

Language: [简体中文](./README.zh-cn.md)

The MBox plugin is used to extend the MBox dependency management capability and add the CocoaPods dependency management.
### Command

The `MBoxCocoapods` plugin will automatically deploy the `Bundler` environment, and then comment all to `CocoaPods`. Therefore, in principle, all the commands native to `CocoaPods` are supported, and the `mbox` entry command is added before the original command:

```
$ mbox pod

  Redirect to CocoaPods with MBox environment
```

The plug-in hooks the `CocoaPods` environment deploy and dependency anlayzer. Taking `mbox pod install` as an example, there will be the following changes:

1. Analyze the `Gemfile` and `Gemfile.lock` in the project, automatically install and use the correct `Bundler`
1. Automatically analyze the `Bundler` environment, and automatically install the required `Gem`
1. Forward commands to `CocoaPods`
1. Read the `Podfile` and `Podfile.lock` in the `CocoaPods` Container, generate a new `Podfile` in the Workspace root directory, and use the `Podfile` as the main `Podfile` of `CocoaPods`
1. If the dependent component has been added to the Workspace, the local repository will be used automatically, without modifying the `Podfile`, and the `Podfile.lock` in the project will not be modified

Notice:
1. If you need to modify the `Podfile`, please modify the `Podfile` in the repository. Do not modify the `Podfile` under Workspace.
1. To add/remove Pod components in Workspace, you need to re-execute `mbox pod install` to update `CocoaPods` dependencies

## Hook

Some capabilities are provided through Hook MBox and CocoaPods:

1. [MBoxCore] `mbox go` will open the `.xcworkspace`/`.xcodeproj` with Xcode
1. [MBoxContainer] Add container for `CocoaPods`
1. [MBoxDependencyManager] Add the dependency management tool for `CocoaPods`

## Dependency

The plugin ONLY works in a workspace.

Dependent MBox components:

1. MBoxCore
1. MBoxGit
1. MBoxRuby
1. MBoxWorkspace
1. MBoxDependencyManager
1. MBoxContainer

Dependent Ruby components:

1. CocoaPods, >= 1.7.0, < 1.11.0

## Installation

1. Activate in workspace:
```
$ mbox plugin enable cocoapods
```

2. Activate in repository, it allow you commit the plugin in git and sync to others:

    Modify the `.mboxconfig` in the repository:
```
{
   "plugins": {
      "MBoxCocoapods": {}
   }
}
```

## Setup
### Setup Container

1. Write a `Gemfile` and add the gems you required
1. Configure the `Workspace/.mboxconfig`:
```
{
   "podfile": "XX/Podfile", 
   # (Required) The relative path of `Podfile` in the repository

   "podlock": "XX/Podfile.lock" 
   #（Optional）The relative path of `Podfile.lock` in the repository. If you have not the lock file, please don't config it.
}
```

### Setup Pod

1. We will search the `*.podspec`/`*.podspec.json` in the root directory of the repository
1. If the `podspec` is not in the root directory, you could configure the relative path in the `.mboxconfig`:
```
{
   # If you have only one podspec
   "podspec": "xx/yy.podspec"

   # If you have more podspecs
   "podspecs": [
      "xx/yy1.podspec",
      "xx/yy2.podspec"
   ]
}
```

## Contributing
Please reference the section [Contributing](https://github.com/MBoxPlus/mbox#contributing)

## License
MBox is available under [GNU General Public License v2.0 or later](./LICENSE).