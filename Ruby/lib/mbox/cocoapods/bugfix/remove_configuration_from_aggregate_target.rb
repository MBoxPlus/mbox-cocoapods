#
# remove base configuration reference for `Pods-xx` target.
# @see https://github.com/CocoaPods/CocoaPods/issues/7934
#
module Pod
  class Installer
    class Xcode
      class PodsProjectGenerator
        class AggregateTargetInstaller < TargetInstaller
          alias_method :mbox_pod_create_xcconfig_file, :create_xcconfig_file
          def create_xcconfig_file(native_target)
            mbox_pod_create_xcconfig_file(native_target)
            native_target.build_configurations.each do |configuration|
              configuration.base_configuration_reference = nil
            end
          end
        end
      end
    end
  end
end
