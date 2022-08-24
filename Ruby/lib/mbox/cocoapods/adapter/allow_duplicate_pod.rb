module Pod
  class Installer
    class Analyzer
      # Replace origin method
      def verify_no_pods_with_different_sources!
        deps_with_different_sources = podfile_dependencies.group_by(&:root_name).
          select { |_root_name, dependencies| dependencies.map(&:external_source).compact.uniq.count > 1 } # << Replace origin method
        deps_with_different_sources.each do |root_name, dependencies|
          raise Informative, 'There are multiple dependencies with different ' \
          "sources for `#{root_name}` in #{UI.path podfile.defined_in_file}:" \
          "\n\n- #{dependencies.map(&:to_s).join("\n- ")}"
        end
      end
    end
  end

  class Lockfile
    # Replace origin method
    def detect_changes_with_podfile(podfile)
      result = {}
      [:added, :changed, :removed, :unchanged].each { |k| result[k] = [] }

      installed_versions = pod_versions.blank? ? {} : pod_versions.map do |name, version|
        { Specification.root_name(name) => version }
      end.reduce(:merge)
      installed_external_sources = external_sources_data.blank? ? {} : external_sources_data.map do |name, hash|
        { Specification.root_name(name) => hash }
      end.reduce(:merge)

      podfile_dependencies = podfile.dependencies
      podfile_dependencies_by_name = podfile_dependencies.group_by(&:root_name)

      all_dep_names = (podfile_dependencies_by_name.keys + dependencies.map(&:root_name)).uniq
      all_dep_names.each do |name|
        podfile_deps = podfile_dependencies_by_name[name]
        key = if podfile_deps.blank?
                :removed
              else
                podfile_dep_with_external_source = podfile_deps.find(&:external_source)
                unless podfile_dep_with_external_source.blank?
                  podfile_external_source = podfile_dep_with_external_source.external_source
                end

                installed_external_source = installed_external_sources[name]

                if installed_external_source != podfile_external_source
                  :changed
                else
                  installed_version = installed_versions[name]
                  if installed_version.blank?
                    :added
                  elsif podfile_deps.find do |dependency|
                    !dependency.requirement.none? && !dependency.requirement.satisfied_by?(installed_version)
                  end
                    :changed
                  else
                    :unchanged
                  end
                end
              end
        result[key] << name
      end
      result
    end
  end
end
