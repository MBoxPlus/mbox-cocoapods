
module Pod
  class Installer
    class SandboxDirCleaner
      alias_method :mbox_pod_clean!, :clean!
      def clean!
        # Because the symbol link will cause the path is different,
        # CocoaPods will remove the `Target Support Files`.
        # So we disable this feature.
      end
    end
  end
end
