module Pod
  class Podfile
    class TargetDefinition

      # 默认使用父集 platform
      alias_method :mbox_pod_multi_platform_initialize_0312, :initialize
      def initialize(name, parent, internal_hash = nil)
        mbox_pod_multi_platform_initialize_0312(name, parent, internal_hash)
        unless root?
          p = parent.platform
          set_platform(p.name, p.deployment_target.to_s) if p
        end
      end

      # 暴露私有函数
      def mbox_pod_platform_value
        get_hash_value('platform')
      end

      # 将未设置 platform 的 subTarget 设置一遍
      alias_method :mbox_pod_set_platform, :set_platform
      def set_platform(name, target = nil)
        mbox_pod_set_platform(name, target)
        children.each do |td|
          if td.mbox_pod_platform_value.nil?
            td.set_platform(name, target)
          end
        end
      end

      # 不再检查 platform 是否已经被设置.
      # 为了保证不和之前的方式冲突，该设置必须放在后面
      alias_method :set_platform!, :set_platform

    end
  end
end
