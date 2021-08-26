
module Pod
    class PodTarget < Target
        def user_targets
            @user_targets ||= begin
                return [] if user_project.nil?

                library_specs.map do |spec|
                    names = spec.name.split('/')
                    user_project.native_targets.find { |target|
                        target.name == names.last ||
                        target.name == names.join ||
                        target.name == names.join("-")
                    }
                end.compact
            end
        end

        def user_project
            @user_project ||= MBox::Config.instance.user_project(pod_name)
        end

        def development?
            if @sandbox.local?(pod_name)
                !user_project.nil?
            else
                false
            end
        end

        alias_method :ori_should_build?, :should_build?
        def should_build?
            return false if development?
            ori_should_build?
        end
    end

    # module Generator
    #     module XCConfig
    #         module XCConfigHelper
    #             class << self
    #                 alias :ori_generate_other_ld_flags :generate_other_ld_flags
    #             end
    #             def self.generate_other_ld_flags(aggregate_target, pod_targets, xcconfig)
    #                 return if aggregate_target and aggregate_target.library?
    #                 ori_generate_other_ld_flags(aggregate_target, pod_targets, xcconfig)
    #             end
    #         end
    #     end
    # end
    class Sandbox
        class FileAccessor
            alias_method :pod_developer_files, :developer_files
            def developer_files
                return [] if MBox::Config.instance.user_project(spec.name)
                pod_developer_files
            end

            alias_method :pod_paths_for_attribute, :paths_for_attribute
            def paths_for_attribute(attribute, include_dirs = false)
                return [] if MBox::Config.instance.user_project(spec.name) && attribute == :source_files
                pod_paths_for_attribute(attribute, include_dirs)
            end
        end
    end

    class Installer
        alias_method :pod_development_pod_targets, :development_pod_targets
        def development_pod_targets(targets = pod_targets)
            pod_development_pod_targets(targets).reject do |pod_target|
                pod_target.development?
            end
        end
    end
end

