
require_relative "dependency"

module Pod
  class Installer
    class Analyzer
      alias_method :mbox_generate_podfile_state_0520, :generate_podfile_state
      def generate_podfile_state
        result = mbox_generate_podfile_state_0520
        ::MBox::Dependency.all.each do |name, dep|
          next if result.changed.include?(name)
          result.changed << name
          result.unchanged.delete name
        end
        result
      end

      alias mbox_dependencies_to_fetch_0518 dependencies_to_fetch
      def dependencies_to_fetch(podfile_state)
        @deps_to_fetch_0518 ||= begin
          deps_to_fetch = mbox_dependencies_to_fetch_0518(podfile_state)
          ::MBox::Dependency.all.values.select(&:external_source).each do |root_name, mbox_dep|
            deps_to_fetch.find_all { |dep| dep.name == root_name }.each do |dep|
              deps_to_fetch.delete(dep)
            end
            deps_to_fetch += mbox_dep.to_dependency
          end
          deps_to_fetch
        end
      end
    end
  end
end
