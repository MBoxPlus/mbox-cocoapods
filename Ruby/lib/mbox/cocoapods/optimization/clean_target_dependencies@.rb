
require 'cocoapods/installer/xcode/pods_project_generator.rb'

# CocoaPods 会对每个 Pod Target 生成依赖列表，方便 Xcode 分析编译顺序。
# 然而，对于 Static Library 来说，编译顺序是无意义的，只要保证依赖比 App 最先编译即可。
# 移除编译依赖，方便做编译缓存检测
# 注意，动态库依然要保留编译顺序！
module Pod
  class Installer
    class InstallationOptions
      option :clean_pod_dependencies, false
    end

    class Xcode
      class PodsProjectGenerator
        def clean_pod_target_dependencies(result)
          if installation_options.clean_pod_dependencies?
            pod_target_installation_results_hash = result.target_installation_results.pod_target_installation_results
            swift_targets = pod_target_installation_results_hash.values.select { |tt| tt.target.uses_swift? }.map { |tt| tt.native_target.name }

            pod_target_installation_results_hash.values.each do |pod_target_installation_result|
              native_target = pod_target_installation_result.native_target
              next if native_target.is_a?(Xcodeproj::Project::PBXNativeTarget) && native_target.dynamic?
              next if pod_target_installation_result.target.uses_swift?

              native_target.dependencies.delete_if do |dp|
                !swift_targets.include?(dp.name) && (dp.target.blank? || !pod_target_installation_result.resource_bundle_targets.include?(dp.target))
              end
            end
          end
        end
      end

      class SinglePodsProjectGenerator
        alias_method :pod_clean_dependency_generate!, :generate!
        def generate!
          result = pod_clean_dependency_generate!
          clean_pod_target_dependencies(result)
          result
        end
      end

      class MultiPodsProjectGenerator
        alias_method :pod_clean_dependency_generate!, :generate!
        def generate!
          result = pod_clean_dependency_generate!
          clean_pod_target_dependencies(result)
          result
        end
      end
    end
  end
end
