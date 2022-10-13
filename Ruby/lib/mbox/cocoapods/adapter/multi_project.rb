module Pod
  class Podfile
    class TargetDefinition

      # Use parent project
      alias_method :mbox_pod_multi_project_initialize_0313, :initialize
      def initialize(name, parent, internal_hash = nil)
        mbox_pod_multi_project_initialize_0313(name, parent, internal_hash)
        unless root?
          up = parent.user_project_path
          self.user_project_path = up if up
          bc = parent.build_configurations
          self.build_configurations = bc if bc
        end
      end

      # make public
      def mbox_pod_user_project_path
        get_hash_value('user_project_path')
      end

      # Set the project for all subtargets
      alias_method :mbox_pod_user_project_path_0313, :user_project_path=
      def user_project_path=(path)
        mbox_pod_user_project_path_0313(path)
        children.each do |td|
          if td.mbox_pod_user_project_path.nil?
            td.user_project_path = path
          end
        end
      end

      # make public
      def mbox_pod_build_configurations
        get_hash_value('build_configurations')
      end

      # Set the build_configurations for all subtargets
      alias_method :mbox_pod_build_configurations_0313, :build_configurations=
      def build_configurations=(hash)
        mbox_pod_build_configurations_0313(hash)
        children.each do |td|
          if td.mbox_pod_build_configurations.blank?
            td.build_configurations = hash
          end
        end
      end

    end
  end
end
