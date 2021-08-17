module MBox
  class Config
    class Feature
      def current_cocoapods_containers
        current_containers_for('CocoaPods')
      end

      def current_cocoapods_container_repos
        repos = current_container_repos_for('CocoaPods')
        return repos unless repos.blank?
        self.repos.select { |repo|
          next false if repo.podfile_path.blank?
          repo.podfile_path.exist?
        }
      end
    end
  end
end
