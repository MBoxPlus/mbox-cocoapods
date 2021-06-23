
#
# 将资源 bundle 透传到 Pods.a 的 Target Dependencies 列表中，
# 防止清空 PodTarget 的 Target Dependencies 列表导致资源没有编译
#
module Pod
  class Installer
    class Xcode
      class PodsProjectGenerator
        alias_method :pod_wire_target_dependencies0627, :wire_target_dependencies
        def wire_target_dependencies(target_installation_results)
          pod_wire_target_dependencies0627(target_installation_results)
          
          pod_target_installation_results_hash = target_installation_results.pod_target_installation_results
          aggregate_target_installation_results_hash = target_installation_results.aggregate_target_installation_results

          aggregate_target_installation_results_hash.values.each do |aggregate_target_installation_result|
            aggregate_target = aggregate_target_installation_result.target
            aggregate_native_target = aggregate_target_installation_result.native_target
            aggregate_target.pod_targets.each do |pod_target|
              pod_target_installation_result = pod_target_installation_results_hash[pod_target.name]
              next if pod_target_installation_result.nil?
              pod_target_installation_result.resource_bundle_targets.each do |resource_bundle_target|
                aggregate_native_target.add_dependency(resource_bundle_target)
              end
            end
          end
        end
      end
    end
  end
end
