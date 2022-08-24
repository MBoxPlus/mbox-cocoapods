# Cocoapods for MBox

其他语言：[English](./README.md)

MBox 的 CocoaPods 插件，用来拓展 MBox 依赖管理能力，添加对 CocoaPods 依赖管理工具的支持

## Command

`MBoxCocoapods` 插件将自动部署 `Bundler` 环境，然后转发所有命令到 `CocoaPods`。因此，原则上支持 `CocoaPods` 原生所有命令，只需在原始命令前加上 `mbox` 入口命令即可：

```
$ mbox pod

  Redirect to Bundler with MBox environment
```

该插件 Hook 了 `CocoaPods` 环境准备，依赖解析等逻辑，以 `mbox pod install` 为例，将会有以下变化：

1. 分析项目中的 `Gemfile` 和 `Gemfile.lock`，自动安装并使用正确的 `Bundler`
1. 自动分析 `Bundler` 环境，自动安装所需 `Gem`
1. 转发命令到 `CocoaPods`
1. 读取 `CocoaPods` Container 中的 `Podfile` 和 `Podfile.lock`，在 Workspace 根目录下生成一个新的 `Podfile`，使用该 `Podfile` 作为 `CocoaPods` 的主 `Podfile`
1. 如果依赖的组件已经添加到 Workspace 中，会自动使用本地仓库，无需修改 `Podfile`，且不会修改项目中的 `Podfile.lock`

注意：
1. 如需修改 `Podfile`，请修改仓库内的 `Podfile`，不要修改 Workspace 下的 `Podfile`。
1. Workspace 中添加/移除 Pod 组件，需要重新执行 `mbox pod install` 更新 `CocoaPods` 依赖关系

## Hook

通过 Hook MBox 和 CocoaPods 提供了一些能力：

1. [MBoxCore] `mbox go` 支持打开 `.xcworkspace`/`.xcodeproj` 项目文件
1. [MBoxContainer] 新增 `CocoaPods` 容器
1. [MBoxDependencyManager] 新增 `CocoaPods` 组件识别能力

## Dependency

该插件只能在 Workspace 下生效

依赖的 MBox 组件：

1. MBoxCore
1. MBoxGit
1. MBoxRuby
1. MBoxWorkspace
1. MBoxDependencyManager
1. MBoxContainer

依赖的 Ruby 组件：

1. CocoaPods, >= 1.7.0, < 1.11.0

## 激活插件

1. 在 Workspace 层级上激活：
```
$ mbox plugin enable cocoapods
```

2. 在 仓库 层级上激活，可以同步给其他拥有该仓库的研发人员：

   修改仓库根目录的 `.mboxconfig` 文件，新增配置：
```
{
   "plugins": {
      "MBoxCocoapods": {}
   }
}
```

## 快速接入

### 主项目/Container 接入

1. 为了保证项目的沙盒化，必须使用 Bundler 进行管理 CocoaPods。请先接入 [MBoxRuby](https://github.com/MBoxPlus/mbox-ruby.git) 容器！
1. 配置 `.mboxconfig`:
   1. 如果 `Podfile` 在项目根目录，则无需额外配置；
   1. 如果 `Podfile` 不在项目根目录下，则需要新增配置：
```json
{
   "cocoapods": {
      "podfile": "XX/Podfile", 
   }
}
```

### 组件/Pod 接入

1. 该插件会自动搜索项目根目录下的 `*.podspec` 或者 `*.podspec.json` 文件
1. 如果 `podspec` 文件不在根目录，需要在项目根目录下 `.mboxconfig` 配置文件中新增配置：

```json
{
   "cocoapods": {
      // 只有一个 podspec 文件
      "podspec": "xx/yy.podspec",

      // 使用通配符匹配文件
      "podspec": "xx/*.podspec",

      // 当存在多个 podspec 文件，可以使用以下形式
      "podspecs": [
         "xx/yy1.podspec",
         "xx/yy2.podspec"
      ]
   }
}
```

如果项目既是 Container 又是 Pod，则需要同时设置上述配置。

## Contributing
Please reference the section [Contributing](https://github.com/MBoxPlus/mbox#contributing)

## License
MBox is available under [GNU General Public License v2.0 or later](./LICENSE).
