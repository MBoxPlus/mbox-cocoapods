
require_relative "dependency"

module Pod
  class Podfile
    class TargetDefinition
      public :get_hash_value
    end
  end

  class Installer
    class Analyzer
      alias mbox_initialize_520 initialize
      def initialize(sandbox, podfile, lockfile = nil, plugin_sources = nil, has_dependencies = true,
                     pods_to_update = false)
        inject_podfile_requirements(podfile)
        mbox_initialize_520(sandbox, podfile, lockfile, plugin_sources, has_dependencies, pods_to_update)
      end

      def inject_podfile_requirements(podfile)
        podfile.target_definition_list.each do |target|
          pods = target.get_hash_value('dependencies') || []
          pods.each do |name_or_hash|
            next unless name_or_hash.is_a?(Hash)
            name = name_or_hash.keys.first
            old_dep = name_or_hash.values.first
            if dep = ::MBox::Dependency.all[Specification.root_name(name)]
              name_or_hash[name] = [dep.to_dependency.requirement.to_s]
              UI.message "[MBox] Podfile Redirect `#{name}` #{old_dep} -> #{name_or_hash[name]}"
            end
          end
        end
      end

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
