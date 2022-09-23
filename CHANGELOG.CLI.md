# 2022/02/22

[Added] 兼容 CocoaPods v1.11.x

[Added] 增加 `cocoapods.podtargets` 映射配置支持。适用于用户本地项目的 target 名和 Pod 名不同的场景以及多个 targets 对应一个 Pod 库的场景。

例如：本地组件仓库对外提供的是一个 Pod，名字叫 `Pod-A`，同时，出于考虑开发时的组件划分，Project 创建了多个 targets，分别是 `target-A`、`target-B`。因此 `Pod-A` 是 `target-A` + `target-B` 的组合，使用自动匹配模式无法满足需求，可通过配置自定义映射和组合关系:

```json
{
    "cocoapods": {
        "podtargets": {
            "Pod-A": [
                "target-A",
                "target-B"
            ]
        }
    }
}
```

[Added] 支持多 `Podfile` 的多容器支持，可以通过 `mbox container use` 命令切换多容器

[Optimize] 自动判断项目中是否有 `Podfile`，如果 `Podfile` 不在根目录，还是得用户在配置文件中指明 `cocoapods.podfile`

[Optimize] 自动判断项目中是否使用 `Podfile.lock` 文件，用户不再需要指明 `cocoapods.podlock` 配置

[Optimize] 生成的 podspec 列表的 sublime 项目 Workspace 将根据名称排序所有 podspec

[Optimize] 现在会自动 Git Ignore 生成的 Pods 符号链接，不需要用户修改项目中的 `.gitignore` 配置

[Optimize] `mbox pod dependencies` 命令现在能获取到更多的信息

[Fixed] 多 Project 模式下，每个 Project 的 Configuration 不一样导致产物路径不同，最终可能链接依赖失败

[Fixed] 多 Podfile 模式下，每个 Podfile 的 `pre_install`/`post_install` 将会在各自的项目路径下执行，避免相对路径变化导致脚本无法执行

[Fixed] 现在执行 `mbox pod update` 不再出错

[Changed] 不再默认禁用 `COCOAPODS_DISABLE_STATS`，如需禁用，需要用户自行控制环境变量
