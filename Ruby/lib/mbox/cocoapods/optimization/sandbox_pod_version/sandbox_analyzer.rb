module Pod
  class Installer
    class Analyzer
      class SandboxAnalyzer
        def installed_version(pod)
          path = VersionFile.path_in_directory(sandbox.pod_dir(pod))
          VersionFile.from_file(path)
        end

        alias_method :mbox_pod_pod_changed_0331?, :pod_changed?
        def pod_changed?(pod)
          if !mbox_pod_pod_changed_0331?(pod)
            if installed = installed_version(pod)
              spec = root_spec(pod)
              return true if installed != spec
            end
            false
          else
            true
          end
        end
      end
    end
  end
end
