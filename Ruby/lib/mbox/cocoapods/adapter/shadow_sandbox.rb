
# 使 Pods 目录能使用原始路径能访问到，防止 Xcode 文件引用中 Pods/xxx.xcconfig 路径变动
module Pod
  # class Sandbox
  #   def root=(root)
  #     root = Pathname(root) if root.is_a?(String)
  #     @root = root.cleanpath
  #   end
  # end

  class Installer
    class UserProjectIntegrator
      class TargetIntegrator
        class XCConfigIntegrator
          class << self
            alias_method :mbox_pod_create_xcconfig_ref, :create_xcconfig_ref
            def create_xcconfig_ref(pod_bundle, config)
              group = config.project['Pods'] || config.project.new_group('Pods', Pathname('Pods'))
              group_path = Pathname.new(group.real_path)
              group_path += pod_bundle.sandbox.root.basename unless group.path
              @@sandbox_links ||= []
              if !@@sandbox_links.include?(group_path) &&
                pod_bundle.sandbox.root != group_path &&
                (!group_path.exist? || group_path.realpath != pod_bundle.sandbox.root.realpath)
                FileUtils.rm_rf(group_path)
                group_dir = group_path.dirname
                group_dir = group_dir.realpath if group_dir.exist?
                origin_path = pod_bundle.sandbox.root.realpath.relative_path_from(group_dir)
                UI.message("Linking #{UI.path(group_path)} -> `#{origin_path}`")
                File.symlink(origin_path, group_path)
                @@sandbox_links << group_path
              end

              # 预先创建 xcconfig 引用，使用 realpath 做相对路径
              xcconfig_path = Pathname.new(pod_bundle.xcconfig_path(config.name))
              filename = xcconfig_path.basename.to_s
              unless group.files.find { |f| f.display_name == filename }
                path = xcconfig_path.realpath.relative_path_from(group_path.realpath)
                group.new_file(path.to_s)
              end

              mbox_pod_create_xcconfig_ref(pod_bundle, config)
            end
          end
        end
      end
    end
  end

  class AggregateTarget
    def create_shadow_sandbox(sandbox, project_root)
      if project_root != sandbox.root.dirname && Config.instance.podfile_path
        shadow_root = project_root + File.basename(sandbox.root)
        origin_path = sandbox.root.realpath.relative_path_from(shadow_root.dirname.realpath)
        if !shadow_root.symlink? || File.readlink(shadow_root) != origin_path.to_s
          UI.message("Create Shadow Sandbox for Project #{UI.path(project_root)}") do
            FileUtils.rm_r(shadow_root) if shadow_root.exist? || shadow_root.symlink?
            UI.message("Linking #{UI.path(shadow_root)} -> `#{origin_path}`")
            File.symlink(origin_path, shadow_root)
          end
        end
      end
    end

    alias_method :mbox_pod_initialize_0107, :initialize
    if Gem::Version.new(Pod::VERSION) >= Gem::Version.new("1.9.0")
      def initialize(sandbox, build_type, user_build_configurations, archs, platform, target_definition, client_root,
                     user_project, user_target_uuids, pod_targets_for_build_configuration)
        create_shadow_sandbox(sandbox, target_definition.sandbox_dir)
        mbox_pod_initialize_0107(sandbox, build_type, user_build_configurations, archs, platform, target_definition, client_root,
                     user_project, user_target_uuids, pod_targets_for_build_configuration)
      end
    else
      def initialize(sandbox, host_requires_frameworks, user_build_configurations, archs, platform, target_definition,
                     client_root, user_project, user_target_uuids, pod_targets_for_build_configuration,
                     build_type: Target::BuildType.infer_from_spec(nil, :host_requires_frameworks => host_requires_frameworks))
        create_shadow_sandbox(sandbox, target_definition.sandbox_dir)
        mbox_pod_initialize_0107(sandbox, host_requires_frameworks, user_build_configurations, archs, platform, target_definition,
          client_root, user_project, user_target_uuids, pod_targets_for_build_configuration, build_type: build_type)
      end
    end
  end

end
