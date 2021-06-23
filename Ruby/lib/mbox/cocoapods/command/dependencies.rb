
module Pod
  class Command
    class Mbox < Command
      class Dependencies < Mbox
        self.summary = 'Show all dependencies from all repos'
        self.description = summary

        def self.options
          [
            ['--output-file=PATH', 'Save the json into a file'],
          ].concat(super)
        end

        self.arguments = [
          CLAide::Argument.new('NAMES', false, true),
        ]

        def initialize(argv)
          @filepath = argv.option("output-file")
          @names = argv.arguments!.map { |name| name.downcase }
          super
        end

        def run
          dps = generate_dependencies
          json = dps.to_json
          UI.info json
          unless @filepath.nil?
            File.write(@filepath, json)
          end
        end

        def search_dependencies
          dependencies_in_lockfile || dependencies_in_podfile || dependencies_in_workspace_lockfile
        end

        def generate_dependencies
          redirect_output do
            search_dependencies || {}
          end
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
          {
            :sources => podfile.sources.map { |url| 
              s = source_with_url(url)
              { s.url => s.repo }
            }.compact,
            :dependencies => podfile.mbox_all_dependencies(@names)
          }
        end

        def dependencies_in_lockfile
          UI.message("Load all lockfiles from all repos")
          lockfile = Pod::Lockfile.load_from_repos
          return nil if lockfile.blank?
          dps = lockfile.mbox_all_dependencies(@names)
          return nil if dps.blank?
          {
            :sources => lockfile.pods_by_spec_repo.keys.map { |url| 
              s = source_with_url(url)
              { s.url => s.repo }
            }.compact,
            :dependencies => dps
          }
        end

        def dependencies_in_workspace_lockfile
          return nil unless MBox::Config::Repo.lockfile_path.exist?
          UI.message("Load workspace lockfile: '#{MBox::Config::Repo.lockfile_path}'")
          lockfile = Lockfile.from_file(MBox::Config::Repo.lockfile_path)
          return nil if lockfile.blank?
          {
            :sources => lockfile.pods_by_spec_repo.keys.map { |url| 
              s = source_with_url(url)
              { s.url => s.repo }
            }.compact,
            :dependencies => lockfile.mbox_all_dependencies(@names)
          }
        end

        def source_with_url(url)
          url = url.downcase.gsub(/.git$/, '')
          url = 'https://github.com/cocoapods/specs' if url =~ %r{github.com[:/]+cocoapods/specs}
          Config.instance.sources_manager.all.find do |source|
            source.name == url || (source.url && source.url.downcase.gsub(/.git$/, '') == url)
          end
        end
      end
    end
  end
end
