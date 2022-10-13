module Pod
  class Podfile
    class TargetDefinition

      # Use the parant platform
      alias_method :mbox_pod_multi_platform_initialize_0312, :initialize
      def initialize(name, parent, internal_hash = nil)
        mbox_pod_multi_platform_initialize_0312(name, parent, internal_hash)
        unless root?
          p = parent.platform
          set_platform(p.name, p.deployment_target.to_s) if p
        end
      end

      # make public
      def mbox_pod_platform_value
        get_hash_value('platform')
      end

      # Set the platform for all subtargets
      alias_method :mbox_pod_set_platform, :set_platform
      def set_platform(name, target = nil)
        mbox_pod_set_platform(name, target)
        children.each do |td|
          if td.mbox_pod_platform_value.nil?
            td.set_platform(name, target)
          end
        end
      end

      # Ignore the platform check
      alias_method :set_platform!, :set_platform

    end
  end
end
