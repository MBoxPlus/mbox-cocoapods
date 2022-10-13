
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
                alias_method :mbox_pod_framework_search_paths_0112, :_raw_framework_search_paths
                def _raw_framework_search_paths
                    mbox_pod_framework_search_paths_0112 + build_dirs
                end

                # @return [Array<String>]
                alias_method :mbox_pod_header_search_paths_0112, :_raw_header_search_paths
                def _raw_header_search_paths
                    mbox_pod_header_search_paths_0112 + build_dirs
                end

                # @return [Array<String>]
                alias_method :mbox_pod_library_search_paths_0112, :_raw_library_search_paths
                def _raw_library_search_paths
                    mbox_pod_library_search_paths_0112 + build_dirs
                end

                def build_dirs
                    target.pod_targets.select(&:development?).map do |pod_target|
                        build_dir_for(pod_target.user_project)
                    end.compact.uniq
                end

                # get `XXX_SEARCH_PATHS` with different configuration
                def build_dir_for(user_project)
                    configuration_names = user_project.build_configurations.map { |configuration| configuration.name }.sort_by { |name| name.length }.reverse
                    if !configuration_names.include?(@configuration_name)
                        configuration = configuration_names.find { |name| @configuration_name.downcase.include?(name.downcase) } || configuration_names.first
                        "${PODS_BUILD_DIR}/#{configuration}$(EFFECTIVE_PLATFORM_NAME)"
                    end
                end
            end
        end
    end

    # class Sandbox
    #     class HeadersStore
    #         alias_method :pod_search_paths, :search_paths
    #         def search_paths(platform, target_name = nil, use_modular_headers = false)
    #             if target_name
    #                 project = MBox::Config.instance.user_project(target_name)
    #                 if project
    #                     return ["$(PODS_CONFIGURATION_BUILD_DIR)", "$(PODS_CONFIGURATION_BUILD_DIR)/#{project.name}"]
    #                 end
    #             end
    #             pod_search_paths(platform, target_name, use_modular_headers)
    #         end
    #     end
    # end

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
