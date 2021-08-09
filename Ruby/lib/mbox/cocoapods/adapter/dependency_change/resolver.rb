
require_relative "dependency"
puts "load MBox specifications_for_dependency"
module Pod
  class Resolver
    alias mbox_initialize_520 initialize
    if Gem::Version.new(Pod::VERSION) >= Gem::Version.new("1.8.0")
      def initialize(sandbox, podfile, locked_dependencies, sources, specs_updated,
                     podfile_dependency_cache: Installer::Analyzer::PodfileDependencyCache.from_podfile(podfile),
                     sources_manager: Config.instance.sources_manager)
        mbox_initialize_520(sandbox, podfile, locked_dependencies, sources, specs_updated,
            podfile_dependency_cache: podfile_dependency_cache,
            sources_manager: sources_manager)
        inject_podfile_requirements
      end
    else
      def initialize(sandbox, podfile, locked_dependencies, sources, specs_updated,
                     podfile_dependency_cache: Installer::Analyzer::PodfileDependencyCache.from_podfile(podfile))
        mbox_initialize_520(sandbox, podfile, locked_dependencies, sources, specs_updated, podfile_dependency_cache: podfile_dependency_cache)
        inject_podfile_requirements
      end
    end

    def inject_podfile_requirements
      ::MBox::Dependency.all.each do |name, dep|
        if @podfile_requirements_by_root_name.key?(name)
          @podfile_requirements_by_root_name[name] = dep.to_dependency.requirement
        end
      end
    end

    alias mbox_search_for_520 search_for
    def search_for(dependency)
      name = dependency.name
      dep = ::MBox::Dependency.all[dependency.root_name]
      if dep
        dependency = dep.to_dependency
        dependency.name = name
        puts "[MBox] Redirect #{dependency.name} -> #{dependency}"
      end
      v = mbox_search_for_520(dependency)
      v
    end

    alias mbox_requirement_satisfied_by_0520? requirement_satisfied_by?
    def requirement_satisfied_by?(requirement, activated, spec)
      result = mbox_requirement_satisfied_by_0520?(requirement, activated, spec)
      return true if result
      return false
    end
  end
end

module Pod
  class Podfile
    alias mbox_initialize_520 initialize
    def initialize(defined_in_file = nil, internal_hash = {}, &block)
      mbox_initialize_520(defined_in_file, internal_hash, &block)
      target_definition_list.each do |target|
        pods = target.get_hash_value('dependencies') || []
        pods.each do |name_or_hash|
          next unless name_or_hash.is_a?(Hash)
          name = name_or_hash.keys.first
          if dep = ::MBox::Dependency.all[Specification.root_name(name)]
            name_or_hash[name] = dep.to_dependency.requirement
          end
        end
      end
    end

    class TargetDefinition
      public :get_hash_value
    end
  end
end
