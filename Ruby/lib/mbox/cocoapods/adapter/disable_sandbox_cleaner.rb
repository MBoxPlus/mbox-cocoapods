
module Pod
  class Installer
    class SandboxDirCleaner
      alias_method :mbox_pod_clean!, :clean!
      def clean!
        # 由于 Target Support Files 存在符号链接，导致路径不一致，会被误删除。
        # 因此暂时禁用清理
      end
    end
  end
end
