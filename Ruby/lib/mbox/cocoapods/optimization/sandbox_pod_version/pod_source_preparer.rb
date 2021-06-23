module Pod
  class Installer
    class PodSourcePreparer
      alias_method :mbox_pod_prepare_0331!, :prepare!
      def prepare!
        mbox_pod_prepare_0331!
        VersionFile.save_specification(path, spec) unless Config.instance.sandbox.local?(spec.name)
      end
    end
  end
end
