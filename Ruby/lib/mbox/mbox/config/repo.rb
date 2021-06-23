
module MBox
  class Config
    class Repo

      def active_components
        return unless info = @components&.find { |c| c["tool"] == "CocoaPods" }
        info["active"]
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
        @podfile_path ||= search_podfile
      end

      def podlock_path
        @podlock_path ||= search_podlock
      end

      def project_path
        @project_path ||= search_project
      end

      def sdk?
        !pod_name.nil?
      end

      def targets
        return [] if project_path.blank?

        Xcodeproj::Project.open(project_path).targets
      end

      private
      
      PODFILE_NAMES = [
        'CocoaPods.podfile.yaml',
        'CocoaPods.podfile',
        'Podfile',
        'Podfile.rb',
      ].freeze

      def search_podfile
        name = setting_for_key("podfile")
        return working_path.join(name) unless name.blank?
        nil
      end

      def search_podspecs
        @search_podspecs ||= begin
          return {} unless working_path.exist?
          name = setting_for_key("podspecs") || setting_for_key("podspec")
          names = name if name.is_a?(Array)
          names = [name] if name.is_a?(String) && !name.blank?
          Dir.chdir(working_path) do
            names = if names.blank?
              Dir["*.podspec.json"] + Dir["*.podspec"]
            else
              names.map do |name|
                Dir[name].select { |n| n.end_with?('.podspec') || n.end_with?('.podspec.json') }
              end.flatten
            end
          end
          return {} if names.blank?
          names.map do |name|
            spec_path = working_path.join(name)
            if spec_path.exist?
              if spec = ::Pod::Specification.from_file(spec_path)
                [spec.name, spec]
              end
            end
          end.compact.to_h
        end
      end
      
      def search_podlock
        return nil unless working_path.exist?
        name = setting_for_key("podlock")
        return nil if name.blank?
        name = Pathname.new(name)
        if name.basename.to_s != 'Podfile.lock'
          name += 'Podfile.lock'
        end
        path + name
      end

      def search_project
        return nil unless working_path.exist?
        name = setting_for_key("xcodeproj")
        if name.blank?
          Dir.chdir(working_path) do
            name = Dir["*.xcodeproj"].reject{ |name| name == "_Pods.xcodeproj" }.first
          end
        end
        name ? working_path.join(name) : nil
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
