
module Pod
  class Podfile
    def mbox_all_dependencies(only_names=nil)
      hash = {}
      dependencies.each do |dp|
        root_name = dp.root_name
        next if !only_names.blank? && !only_names.include?(root_name.downcase)
        req = (dp.external_source || {}).dup
        req[:source] = dp.podspec_repo if dp.podspec_repo
        if version = dp.specific_version || dp.requirement.requirements.select { |k, v| k == "=" }.map { |_, v| v }.first
          req[:version] = version
        end
        if hash[root_name]
          hash[root_name].merge!(req)
        else
          hash[root_name] = req
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
        hash[name] = { :version => version } if hash[name].nil?
      end
      external_sources_data.each do |name, data|
        next if !only_names.blank? && !only_names.include?(name.downcase)
        if hash[name]
          hash[name].merge!(data)
        else
          hash[name] = data.dup
        end
      end
      checkout_options_data.each do |name, data|
        next if !only_names.blank? && !only_names.include?(name.downcase)
        if hash[name]
          hash[name].merge!(data)
        else
          hash[name] = data.dup
        end
      end
      hash.each do |name, data|
        source = spec_repo(name)
        data["source"] = source if source
      end

      hash
    end
  end
end
