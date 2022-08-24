
module Pod
  class Command
    class Mbox < Command
      class Dependencies < Mbox
        self.summary = 'Show all dependencies from all repos'
        self.description = summary

        def self.options
          [
            ['--output-file=PATH', 'Save the json into a file'],
            ['--detailed', 'Show more detail infomation of these dependencies']
          ].concat(super)

        end

        self.arguments = [
          CLAide::Argument.new('NAMES', false, true),
        ]

        def initialize(argv)
          @filepath = argv.option("output-file")
          @detailed = argv.flag?('detailed')
          super
          @names = argv.arguments!.map { |name| name.downcase }
        end

        def run
          json = {}
          redirect_output do
            dps = generate_dependencies
            UI.message("Fill external information")
            detailed_dependencies(dps)

            dps = dps.map { |name, dependency|
              [name.downcase, to_hash(dependency)]
            }.to_h

            json = dps.to_json
          end

          if @filepath.nil?
            UI.puts json
          else
            File.write(@filepath, json)
          end
        end

        def to_hash(dependency)
          v = {
            "name": dependency.name,
            "version": dependency.specific_version
          }
          return v if dependency.external_source.blank?
          v.merge(dependency.external_source)
        end

        def search_dependencies
          dps = dependencies_in_lockfile || dependencies_in_podfile
          if dps && dps.all? { |_, value| !value.blank? }
            return dps
          end
          dps2 = dependencies_in_workspace_lockfile
          return dps2 if dps.blank?
          dps.each do |name, value|
            v2 = dps2[name]
            next if v2.blank?
            next if value.any? { |k, v|
              v2[k] != v
            }
            dps[name] = v2
          end
          dps
        end

        def generate_dependencies
          v = search_dependencies || {}
          v.each do |name, dp|
            if dp.specific_version.nil? && dp.requirement.exact?
              dp.specific_version = dp.requirement.requirements[0][1]
            end
          end
          v
        end

        def spec_set_for(dependency)
          config.sources_manager.aggregate_for_dependency(dependency).search(dependency)
        end

        def source_for(dependency, spec_set)
          spec_paths = {}
          version = dependency.specific_version

          sources = spec_set.sources.select do |source|
            versions = spec_set.versions_by_source[source]
            next if versions.nil?
            versions.include?(version)
          end
          sources.each do |source|
            if spec_path = source.specification_path(dependency.name, version)
              spec_paths[source] = spec_path
            end
          end
          spec_paths
        end

        def fill_depependency_with_podspec(dependency, spec)
          dependency.external_source[:authors] ||= spec.authors
          dependency.external_source.merge!(spec.source)
          dependency.external_source.merge!(spec.source_code) unless spec.source_code.blank?
        end

        def fill_dependency(dependency, cache)
          if item = cache[dependency.name.downcase]
            if Version.new(item["version"]) == dependency.specific_version
              dependency.external_source.merge!(item)
              return
            end
          end

          spec_set = spec_set_for(dependency)
          source_for(dependency, spec_set).each do |source, path|
            begin
              if @detailed
                spec = Pod::Specification.from_file(path)
                fill_depependency_with_podspec(dependency, spec)
              end
              dependency.podspec_repo = source.url
              dependency.external_source[:podspec] = path
              dependency.external_source[:source] = {
                "url": source.url,
                "name": source.name,
                "path": source.repo.to_s
              }
              return
            rescue
            end
          end

          UI.warn "Could not find podspec for dependency #{dependency}"
        end

        def podspec_cache
          path = Config.instance.podfile_path.dirname + "podspecs.yaml"
          if path.exist?
            YAML.load_file(path)
          else
            {}
          end
        end

        def detailed_dependencies(dps)
          require 'concurrent'
          executers = []
          cache = self.podspec_cache
          dps.each do |name, dep|
            executer = Concurrent::Future.execute {
              dep.external_source ||= {}
              fill_dependency(dep, cache)
            }
            executers << executer
          end
          executers.each { |executer| executer.value }
        end

        def redirect_output
          original_stdout= $stdout.clone
          $stdout.reopen $stderr
          yield
        ensure
          $stdout.reopen original_stdout
        end

        def dependencies_in_podfile
          UI.message("Load all podfiles from all repos")
          podfile = Podfile.from_mbox
          return nil unless podfile
          podfile.mbox_all_dependencies(@names)
        end

        def dependencies_in_lockfile
          UI.message("Load all lockfiles from all repos")
          lockfile = Pod::Lockfile.load_from_repos
          return nil if lockfile.blank?
          lockfile.mbox_all_dependencies(@names)
        end

        def dependencies_in_workspace_lockfile
          return nil unless MBox::Config::Repo.lockfile_path.exist?
          UI.message("Load workspace lockfile: '#{MBox::Config::Repo.lockfile_path}'")
          lockfile = Lockfile.from_file(MBox::Config::Repo.lockfile_path)
          return nil if lockfile.blank?
          lockfile.mbox_all_dependencies(@names)
        end
      end
    end
  end
end
