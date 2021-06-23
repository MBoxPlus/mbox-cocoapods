
module Pod
  class Command
    class Mbox < Command
      class Spec < Mbox
        self.summary = 'Show spec info'
        self.description = summary

        self.arguments = [
          CLAide::Argument.new('NAME', true),
        ]

        def self.options
          [
              ['--version=VERSION', 'The version to query.'],
              ['--source=SOURCE', 'The spec repo to query.'],
              ['--path=PATH', 'The path to query'],
              ['--show-source', 'Add `source` key to result.'],
              ['--output-file=PATH', 'Save the json into a file'],
          ].concat(super)
        end

        def initialize(argv)
          @name = argv.shift_argument
          @filepath = argv.option("output-file")
          @version = argv.option('version')
          @source = argv.option('source')
          @path = argv.option('path')
          @show_source = argv.flag?('show-source', false)
          super
        end

        def run
          spec = find_spec
          if spec.nil?
            raise "Failed to find specification `#{@name}` by version: `#{@version}`, source: `#{@source}`, path: `#{@path}`. Please run `mbox pod repo update`."
            return
          end
          json = spec.to_json
          UI.info json
          unless @filepath.nil?
            File.write(@filepath, json)
          end
        end

        def find_spec
          if @path.blank?
            dependency = Dependency.new(@name, @version, {:source => @source})
            aggregate = config.sources_manager.aggregate_for_dependency(dependency)
            set = aggregate.search(dependency)
            if @version
              version = Version.new(@version)
            else
              version = set.highest_version
            end

            first_source = nil
            version_by_source = set.sources.each_with_object({}) do |source, hash|
              real_version = set.versions_by_source[source].find { |v| v == version }
              hash[source] = real_version if real_version
              first_source = source if real_version.to_s == @version
            end
            if first_source.nil?
              result_source = version_by_source.keys.first
              sepc_path = version_by_source.map { |source, v| source.specification_path(@name, v) }.first
            else
              result_source = first_source
              sepc_path = first_source.specification_path(@name, version)
            end
            spec = Specification.from_file(sepc_path) unless sepc_path.nil?
          else
            spec = Specification.from_file(Pathname.new(@path))
          end
          spec.attributes_hash["mbox_repo_source"] = result_source.url if @show_source && !result_source.nil?
          spec
        end
      end
    end
  end
end
