
module Pod
  class Podfile
    class TargetDefinition
      def mbox_devspecs
        podspecs = get_hash_value('podspecs')
        return nil if podspecs.blank? || podspecs.count > 1
        options = podspecs.first
        file = podspec_path_from_options(options)
        spec = Specification.from_file(file)
        subspec_names = options[:subspecs] || options[:subspec]
        if subspec_names.blank?
          [spec]
        else
          subspec_names = [subspec_names] if subspec_names.is_a?(String)
          subspec_names.map { |subspec_name| spec.subspec_by_name("#{spec.name}/#{subspec_name}") }
        end
      end
    end
  end

  class Target
    class BuildSettings
      class AggregateTargetSettings
        alias_method :mbox_pod_xcconfig_0812, :_raw_xcconfig
        define_build_settings_method :xcconfig, :memoized => true do
          xcconfig = mbox_pod_xcconfig_0812
          if devspecs = target.target_definition.mbox_devspecs
            devspecs.map do |devspec|
              target.pod_targets.find do |pod_target|
                pod_target.specs.all? { |spec| spec.name == devspec.name }
              end
            end.compact.map(&:build_settings).each do |settings|
              merge_spec_xcconfig_into_xcconfig(settings.xcconfig, xcconfig)
            end
          end
          xcconfig
        end
      end
    end
  end
end
