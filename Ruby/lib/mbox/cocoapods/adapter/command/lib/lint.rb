module Pod
  class Validator
    alias_method :mbox_pod_podfile_from_spec_0329, :podfile_from_spec
    if Gem::Version.new(Pod::VERSION) >= Gem::Version.new("1.10.0")
      def podfile_from_spec(platform_name, deployment_target, use_frameworks = true, test_spec_names = [], use_modular_headers = false, use_static_frameworks = false)
        mbox_pod_podfile_from_spec_0329(platform_name, deployment_target, use_frameworks, test_spec_names, use_modular_headers, use_static_frameworks).tap do |podfile|
          mbox_install!(podfile)
        end
      end
    else
      def podfile_from_spec(platform_name, deployment_target, use_frameworks = true, test_spec_names = [], use_modular_headers = false)
        mbox_pod_podfile_from_spec_0329(platform_name, deployment_target, use_frameworks, test_spec_names, use_modular_headers).tap do |podfile|
          mbox_install!(podfile)
        end
      end
    end

    def mbox_install!(podfile)
      if mbox_podfile = config.podfile
        installation_method = mbox_podfile.installation_method
        podfile.install!(installation_method[0], installation_method[1])
      end
    end

    alias_method :mbox_pod_validation_dir_0506, :validation_dir
    def validation_dir
      @validation_dir ||= mbox_pod_validation_dir_0506.realpath
    end
  end

  class Command
    class Lib
      class Lint
        alias_method :mbox_pod_initialize_0329, :initialize
        def initialize(argv)
          config.write_independent_lockfile = false
          args = argv.remainder

          sources = argv.option('sources')
          if sources.blank? && (podfile = config.podfile)
            sources = podfile.sources
          end
          args << "--sources=#{sources.join(',')}" unless sources.blank?

          uses_frameworks  = !argv.flag?('use-libraries')
          if uses_frameworks
            uses_frameworks = podfile.root_target_definitions.any?(&:uses_frameworks?)
          end
          args << '--use-libraries' unless uses_frameworks

          mbox_pod_initialize_0329(CLAide::ARGV.coerce(args))
        end

        alias_method :mbox_pod_podspecs_to_lint_0329, :podspecs_to_lint
        def podspecs_to_lint
          if !@podspecs_paths.empty?
            Array(@podspecs_paths).map do |path|
              if !path.downcase.end_with?('.podspec') && !path.downcase.end_with?('.podspec.json')
                Dir[Pathname.new(path) + '*.podspec{.json,}']
              else
                path
              end
            end.flatten
          else
            podspecs = Pathname.glob(config.installation_root + '*/*.podspec{.json,}')
            if podspecs.count.zero?
              raise Informative, 'Unable to find any podspecs in the repos'
            end
            podspecs
          end
        end
      end
    end
  end
end
