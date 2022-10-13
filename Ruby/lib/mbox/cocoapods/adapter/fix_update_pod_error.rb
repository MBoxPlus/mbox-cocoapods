module Pod
  class Command
    class Update
      alias_method :mbox_lockfile_missing_pods_0315, :lockfile_missing_pods
      def lockfile_missing_pods(pods)
        v = mbox_lockfile_missing_pods_0315(pods)
        path = MBox::Config::Repo.lockfile_path
        if path.exist?
          lockfile = Pod::Lockfile.from_file(path)
          lockfile_roots = lockfile.pod_names.map { |pod| Specification.root_name(pod) }
          v = v - lockfile_roots
        end
        v
      end
    end
  end
end
