module Pod
  class Sandbox
    class PodDirCleaner
      alias_method :mbox_pod_clean_0229!, :clean!
      def clean!
      	# 防止 link 到本地仓库的时候，被无意中执行了 clean 逻辑，导致代码丢失
        return if root.symlink?
        mbox_pod_clean_0229!
      end
    end
  end
end
