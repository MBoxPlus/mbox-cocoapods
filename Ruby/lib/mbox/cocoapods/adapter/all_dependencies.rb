
module Pod
  class Podfile
    def mbox_all_dependencies(only_names=nil)
      hash = {}
      dependencies.each do |dp|
        dp = dp.to_root_dependency
        next if !only_names.blank? && !only_names.include?(dp.name.downcase)
        if dp2 = hash[dp.name]
          dp2.merge(dp)
        else
          hash[dp.name] = dp
        end
      end
      hash
    end
  end

  class Lockfile
    def mbox_all_dependencies(only_names=nil)
      hash = {}

      pod_versions.each do |name, version|
        name = Specification.root_name(name)
        next if !only_names.blank? && !only_names.include?(name.downcase)
        if hash[name].nil?
          hash[name] = Dependency.new(name, version)
        end
      end
      external_sources_data.each do |name, data|
        next if !only_names.blank? && !only_names.include?(name.downcase)
        if dep = hash[name]
          dep.external_source = data.dup
        end
      end
      checkout_options_data.each do |name, data|
        next if !only_names.blank? && !only_names.include?(name.downcase)
        if dep = hash[name]
          dep.external_source.merge!(data)
        end
      end
      hash.each do |name, dep|
        source = spec_repo(name)
        dep.podspec_repo = source if source
      end

      hash
    end
  end
end
