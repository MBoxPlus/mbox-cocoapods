
module Pod
    class Target
        class BuildSettings
            define_build_settings_method :excluded_recursive_search_path_subdirectories, :build_setting => true, :memoized => true do
                '$(inherited) Build Pods build'
            end

            class AggregateTargetSettings < BuildSettings

                # @return [Array<String>]
                define_build_settings_method :other_ldflags, :build_setting => true, :memoized => true do
                    if target.user_project
                        return ['-ObjC'] if target.user_targets.find { |native_target| native_target.static? }
                    end
                    ld_flags = super().dup
                    target.pod_targets.select(&:development?).each do |pod_target|
                        pod_target.user_targets.each do |dependency_target|
                            case dependency_target.symbol_type
                            when :framework
                                ld_flags << '-framework' << %("#{dependency_target.link_product_name}")
                            when :dynamic_library, :static_library
                                ld_flags << %(-l"#{dependency_target.link_product_name}")
                            end
                        end
                    end
                    ld_flags
                end

                # @return [Array<String>]
                define_build_settings_method :framework_search_paths, :build_setting => true, :memoized => true, :sorted => true, :uniqued => true, :from_pod_targets_to_link => true, :from_search_paths_aggregate_targets => :framework_search_paths_to_import do
                    ["$(PODS_CONFIGURATION_BUILD_DIR)"]
                end

                # @return [Array<String>]
                alias_method :pod_header_search_paths, :_raw_header_search_paths
                define_build_settings_method :header_search_paths, :build_setting => true, :memoized => true, :sorted => true, :uniqued => true do
                    paths = pod_header_search_paths.dup
                    target.pod_targets.select(&:development?).each do |pod_target|
                        if target.user_project != pod_target.user_project
                            paths << %(${PODS_CONFIGURATION_BUILD_DIR}/#{pod_target.user_project.name})
                        end
                    end

                    paths << "$(PODS_CONFIGURATION_BUILD_DIR)"
                    paths
                end

                alias_method :pod_library_search_paths, :_raw_library_search_paths
                def _raw_library_search_paths
                    ["$(PODS_CONFIGURATION_BUILD_DIR)"]
                end
            end
        end
    end

    class Sandbox
        class HeadersStore
            alias_method :pod_search_paths, :search_paths
            def search_paths(platform, target_name = nil, use_modular_headers = false)
                if target_name
                    project = MBox::Config.instance.user_project(target_name)
                    if project
                        return ["$(PODS_CONFIGURATION_BUILD_DIR)", "$(PODS_CONFIGURATION_BUILD_DIR)/#{project.name}"]
                    end
                end
                pod_search_paths(platform, target_name, use_modular_headers)
            end
        end
    end

    # class Installer
    #     class Xcode
    #         class PodsProjectGenerator
    #             alias_method :pod_generate!, :generate!
    #             def generate!
    #                 pod_generate!
    #                 frameworks_group = project.frameworks_group
    #                 aggregate_target_installation_results_hash = @target_installation_results.aggregate_target_installation_results
    #                 aggregate_target_installation_results_hash.values.each do |aggregate_target_installation_result|
    #                     aggregate_native_target = aggregate_target_installation_result.native_target
    #                     aggregate_target = aggregate_target_installation_result.target
    #                     aggregate_target.pod_targets.each do |pod_target|
    #                         pod_target.user_targets.each do |target|
    #                             case target.symbol_type
    #                             when :framework
    #                                 product_ref = frameworks_group.files.find { |f| f.path == "#{target.product_name}.framework" } ||
    #                                     frameworks_group.new_product_ref_for_target(target.product_name, :framework)
    #                                 aggregate_native_target.frameworks_build_phase.add_file_reference(product_ref, true)
    #                             when :dynamic_library, :static_library
    #                                 UI.warn "Type `library` of target `#{target.name}` in project `#{target.project.name} is NOT supported."
    #                             end
    #                         end
    #                     end
    #                 end
    #             end
    #         end
    #     end
    # end
end
