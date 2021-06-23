
module Pod
  class Config
    alias_method :mbox_pod_with_changes_0327, :with_changes
    def with_changes(changes)
      mbox_pod_with_changes_0327(changes) do
        MBox::Config.instance.with_changes(changes) do
          yield if block_given?
        end
      end
    end
  end
end

module MBox
  module UserInterface
    # module ErrorReport
    #   extend ::Pod::UserInterface::ErrorReport
    # end

    class << self
      # Prints the textual representation of a given set.
      #
      # @param  [Set] set
      #         the set that should be presented.
      #
      # @param  [Symbol] mode
      #         the presentation mode, either `:normal` or `:name_and_version`.
      #
      def pod(set, mode = :normal)
        if mode == :name_and_version
          puts_indented "#{set.name} #{set.versions.first.version}"
        else
          pod = ::Pod::Specification::Set::Presenter.new(set)
          title = "-> #{pod.name} (#{pod.version})"
          if pod.spec.deprecated?
            title += " #{pod.deprecation_description}"
            colored_title = title.red
          else
            colored_title = title.green
          end

          title(colored_title, '', 1) do
            puts_indented pod.summary if pod.summary
            puts_indented "pod '#{pod.name}', '~> #{pod.version}'"
            labeled('Homepage', pod.homepage)
            labeled('Source',   pod.source_url)
            labeled('Versions', pod.versions_by_source)
            if mode == :stats
              labeled('Authors',  pod.authors) if pod.authors =~ /,/
              labeled('Author',   pod.authors) if pod.authors !~ /,/
              labeled('License',  pod.license)
              labeled('Platform', pod.platform)
              labeled('Stars',    pod.github_stargazers)
              labeled('Forks',    pod.github_forks)
            end
            labeled('Subspecs', pod.subspecs)
          end
        end
      end
    end
  end
end

## Redirect UI
MBox::UserInterface::ErrorReport = Pod::UserInterface::ErrorReport

Pod.send(:remove_const, :UserInterface)
Pod::UserInterface = MBox::UserInterface

Pod.send(:remove_const, :UI)
Pod::UI = MBox::UI

## Redirect Executable
Pod.send(:remove_const, :Executable)
Pod::Executable = MBox::Executable

# module MBox
#   module UserInterface
#     module ErrorReport
#       class << self
#         def markdown_podfile
#           return '' unless ::Pod::Config.instance.podfile_path && ::Pod::Config.instance.podfile_path.exist?
#           <<-EOS

# ### Podfile

# ```ruby
# #{::Pod::Config.instance.podfile_path.read.strip}
# ```
# EOS
#         end
#       end
#     end
#   end
# end
