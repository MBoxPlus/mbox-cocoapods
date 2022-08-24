
# List all podspecs, generate a sublime project
module Pod
  class Installer
    class Analyzer
      alias_method :mbox_pod_specs_analyze, :analyze
      def analyze(allow_fetches = true)
        mbox_pod_specs_analyze(allow_fetches).tap do |result|
          podfile_path = @podfile.defined_in_file
          return if podfile_path.nil?
          specs_by_source = result.specs_by_source.transform_values { |specs| specs.map { |s| s.root }.uniq(&:name).sort_by(&:name) }
          self.generate_specifications_yaml(specs_by_source)
          self.generate_sublime_project(specs_by_source)
        end
      end

      def generate_yaml_for_specification(spec, source)
        dict = {
          "name": spec.name,
          "version": spec.version.to_s,
          "podspec": spec.defined_in_file.to_s,
          "homepage": spec.homepage,
          "authors": spec.authors
        }
        dict["source"] = {
          "name": source.name,
          "url": source.url,
          "path": source.repo.to_s
        } if source
        dict.merge!(spec.source) unless spec.source.blank?
        dict.merge!(spec.source_code) unless spec.source_code.blank?
        dict
      end

      def generate_specifications_yaml(specs_by_source)
        value = {}
        specs_by_source.each do |source, specs|
          specs.each do |spec|
            value[spec.name.downcase] = generate_yaml_for_specification(spec, source).deep_transform_keys(&:to_s)
          end
        end
        File.write(@podfile.defined_in_file.dirname + "podspecs.yaml", value.to_yaml)
      end

      def generate_sublime_project(specs_by_source)
        sublime = {
          "folders": specs_by_source.values.flatten.map { |spec|
            {
              "path": spec.defined_in_file.dirname,
              "name": spec.name,
              "folder_exclude_patterns": ["**/**"],
              "file_include_patterns": [spec.defined_in_file.basename]
            }
          }
        }
        File.write(@podfile.defined_in_file.dirname + "podspecs.sublime-project", JSON.pretty_generate(sublime))
      end
    end
  end
end
