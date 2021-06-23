module Pod
  module Generator
    class CopyResourcesScript
      alias_method :pod_script, :script
      def script
        script = pod_script
        script.sub!("\n\n", "\n\nruby \"$(dirname \"$0\")/../copy-framework-resources.rb\"\n\n")
        script.sub!("rm -f \"$RESOURCES_TO_COPY\"", %(rm -f \"$RESOURCES_TO_COPY\"

OTHER_XCASSETS=$(find "$PWD/.tmpassets" -iname "*.xcassets")
while read line; do
  if [[ $line != "${PODS_ROOT}*" ]]; then
    XCASSET_FILES+=("$line")
  fi
done <<<"$OTHER_XCASSETS"
))
        script << "rm -rf '.tmpassets'"
      end
    end
  end

  class AggregateTarget < Target
    def copy_framework_resources_script_path
      support_files_dir + "../copy-framework-resources.rb"
    end
    def copy_framework_resources_script_relative_path
      "${PODS_ROOT}/#{relative_to_pods_root(copy_framework_resources_script_path)}"
    end
    def keep_assets_script_path
      support_files_dir + "#{label}-assets.rb"
    end
    def keep_assets_script_relative_path
      "${PODS_ROOT}/#{relative_to_pods_root(keep_assets_script_path)}"
    end
  end

  class Installer
    class Xcode
      class PodsProjectGenerator
        class AggregateTargetInstaller < TargetInstaller
          alias_method :pod_create_copy_resources_script, :create_copy_resources_script
          def create_copy_resources_script
            create_keep_assets_script
            create_copy_framework_resources_script
            pod_create_copy_resources_script
          end

          def create_keep_assets_script
            path = target.keep_assets_script_path
            script_path = File.expand_path('../../../../XCodeScript/KeepAssetsInFramework/keep-assets-in-framework.rb', __FILE__)
            create_custom_script(script_path, path)
          end
          def create_copy_framework_resources_script
            path = target.copy_framework_resources_script_path
            script_path = File.expand_path('../../../../XCodeScript/CopyFrameworkResources/copy-framework-resources.rb', __FILE__)
            create_custom_script(script_path, path)
          end

          def create_custom_script(script_path, path)
            if !path.exist? || !FileUtils.identical?(script_path, path)
              FileUtils.cp(script_path, path)
              File.chmod(0755, path.to_s)
            end
            add_file_to_support_group(path)
          end
        end
      end
    end

    class UserProjectIntegrator
      class TargetIntegrator
        KEEP_ASSETS_PACKAGE_PHASE_NAME = 'Keep Assets Package'.freeze

        alias_method :pod_add_copy_resources_script_phase, :add_copy_resources_script_phase
        def add_copy_resources_script_phase
          pod_add_copy_resources_script_phase
          phase_name = BUILD_PHASE_PREFIX + COPY_PODS_RESOURCES_PHASE_NAME
          # if user target is a static framework, we will keep `.xcassets`.
          # The `.xcassets` must be compiled to `.car` in host app, we can not merge multi `.car` to one.
          native_targets.each do |native_target|
            if native_target.symbol_type == :framework
              if native_target.common_resolved_build_setting("MACH_O_TYPE") == 'staticlib'
                script_path = "#{target.keep_assets_script_relative_path}"
                TargetIntegrator.create_or_update_keep_assets_script_phase_to_target(native_target, script_path)
              else
                TargetIntegrator.remove_keep_assets_script_phase_from_target(native_target)
              end
            else
                build_phases = native_target.build_phases.grep(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
                phase = build_phases.find { |phase| phase.name && phase.name.end_with?(phase_name) }.tap { |p| p.name = phase_name if p }
                phase.shell_path = "/bin/sh -l" if phase
            end
          end
        end

        class << self
          def remove_keep_assets_script_phase_from_target(native_target)
            build_phase = native_target.shell_script_build_phases.find { |bp| bp.name && bp.name.end_with?(KEEP_ASSETS_PACKAGE_PHASE_NAME) }
            return unless build_phase.present?
            native_target.build_phases.delete(build_phase)
          end

          def create_or_update_keep_assets_script_phase_to_target(native_target, script_path, input_paths = [], output_paths = [])
            phase_name = KEEP_ASSETS_PACKAGE_PHASE_NAME
            phase = TargetIntegrator.create_or_update_build_phase(native_target, BUILD_PHASE_PREFIX + phase_name)
            phase.shell_script = %("#{script_path}"\n)
            phase.input_paths = input_paths
            phase.output_paths = output_paths
            phase.shell_path = "/bin/sh -l"
          end
        end
      end
    end
  end
end
