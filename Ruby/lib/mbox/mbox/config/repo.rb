
module MBox
  class Config
    class Repo

      def active_components
        return unless info = @components&.find { |c| c["tool"] == "CocoaPods" }
        info["active"]
      end

      alias_method :mbox_cocoapods_all_containers_0923, :all_containers
      def all_containers
        cocoapods_containers = podfile_paths.map { |name, _|
          Feature::Container.new(name, self.name, "CocoaPods")
        }
        mbox_cocoapods_all_containers_0923 + cocoapods_containers
      end

      def pod_name
        pod_names.first
      end

      def pod_names
        @pod_names ||= podspec_paths.keys
      end

      def podspec
        podspecs.first
      end

      def podspecs
        search_podspecs.values
      end

      def podspec_path
        podspec_paths.values.first
      end

      def podspec_paths
        @podspec_paths ||= search_podspecs.map { |name, spec| [name, spec.defined_in_file] }.to_h
      end

      def podfile_path
        return nil if podfile_paths.nil? || podfile_paths.blank?
        podfile_paths.values.first
      end

      def podfile_paths
        @podfile_paths ||= search_podfiles
      end

      def podfile_path_by_name(name)
        podfile_paths.transform_keys { |k| k.downcase }[name.downcase]
      end

      def podlock_paths
        @podlock_paths ||= search_podlocks
      end

      def podlock_path_by_name(name)
        podlock_paths.transform_keys { |k| k.downcase }[name.downcase]
      end

      def project_paths
        @project_paths ||= search_projects
      end

      def project_path_by_name(name)
        project_paths.transform_keys { |k| k.downcase }[name.downcase]
      end

      def pod_targets
        setting_for_key("cocoapods.podtargets") || {}
      end

      def pod_targets_by_name(name)
        v = pod_targets.transform_keys { |k| k.downcase }[name.downcase]
        return nil if v.blank?
        v.keys
      end

      def sdk?
        !pod_name.nil?
      end

      private
      
      PODFILE_NAMES = [
        'CocoaPods.podfile.yaml',
        'CocoaPods.podfile',
        'Podfile',
        'Podfile.rb',
      ].freeze

      def search_podfiles
        filenames = setting_for_key("cocoapods.podfiles") || {}
        if v = setting_for_key("cocoapods.podfile")
          filenames[self.name] = v
        end

        paths = filenames.transform_values { |file|
          working_path.join(file)
        }.select { |_, path|
          path.exist?
        }

        if paths.blank?
          path = PODFILE_NAMES.map { |file| working_path.join(file) }.find { |path| path.exist? }
          if path
            paths[self.name] = path
          end
        end

        paths
      end

      def search_podspecs
        @search_podspecs ||= begin
          return {} unless working_path.exist?
          specs = paths_for_setting("cocoapods.podspecs", singular: "cocoapods.podspec", defaults: ["*.podspec{.json,}"])
          return {} if specs.blank?
          specs.map do |spec_path|
            if spec = ::Pod::Specification.from_file(spec_path)
              [spec.name, spec]
            end
          end.compact.to_h
        end
      end
      
      def search_podlocks
        return {} unless podfile_paths
        locks = podfile_paths.transform_values { |path| path.dirname + "Podfile.lock" }
        Dir.chdir(working_path) do
          locks.select { |_, path|
            `git ls-files --error-unmatch '#{path}' 2>/dev/null`
            $? == 0
          }
        end
      end

      def search_projects
        return {} unless working_path.exist?
        return {} if podfile_paths.blank?
        podfile_paths.transform_values { |path|
          dir = path.dirname
          Dir.chdir(dir) do
            if file = Dir["*.xcodeproj"].reject{ |name| name == "_Pods.xcodeproj" }.first
              dir.join(file)
            end
          end
        }.compact
      end

      public

      class << self
        def workspace_path
          Dir[Config.instance.project_root + "*.xcworkspace"].first || Config.instance.project_root + "#{Config.instance.project_root.basename}.xcworkspace"
        end

        def podfile_path
          Config.instance.project_root + "Podfile"
        end

        def lockfile_path
          Config.instance.project_root + "Podfile.lock"
        end

        def pod_sandbox_path
          Config.instance.project_root + "Pods"
        end

        def manifest_path
          pod_sandbox_path + "Manifest.lock"
        end

        def should_install?
          return false unless lockfile_path.exist?
          require 'fileutils'
          return !manifest_path.exist? || !FileUtils.compare_file(lockfile_path.to_s, manifest_path.to_s)
        end
      end
    end
  end
end
