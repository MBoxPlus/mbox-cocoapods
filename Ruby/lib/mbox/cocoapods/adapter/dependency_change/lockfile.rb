
module Pod
  class Lockfile
    alias_method :mbox_detect_changes_with_podfile_0519, :detect_changes_with_podfile
    def detect_changes_with_podfile(podfile)
      result = mbox_detect_changes_with_podfile_0519(podfile)
      ::MBox::Dependency.all.each do |name, dep|
        next if result.include?(name)
        if version = dep.version && self.version(name) != version
          result[:changed] << name
        end
      end
      result
    end
  end
end
