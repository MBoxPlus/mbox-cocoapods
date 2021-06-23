#
# 当执行 pod install 时，由于未更新 repo 仓库，导致新版本找不到。
# 当出现该问题时，尝试更新一下 repo 仓库，再执行一遍版本仲裁，如果还是找不到，才抛出异常。
#
module Pod
  class Installer
    class Analyzer
      alias_method :pod_resolve_dependencies_0706, :resolve_dependencies
      def resolve_dependencies(locked_dependencies)
        pod_resolve_dependencies_0706(locked_dependencies)
      rescue NoSpecFoundError, Molinillo::VersionConflict, Molinillo::NoSuchDependencyError, Informative => e
        raise if @specs_updated
        raise if e.is_a?(Informative) && !e.message.include?("`pod repo update`") && !e.message.include?("`pod update ")
        raise if e.is_a?(Molinillo::VersionConflict) && !e.message.include?("pre-release")
        UI.section 'Updating local specs repositories' do
          update_repositories
        end
        pod_resolve_dependencies_0706(locked_dependencies)
      end
    end
  end
end
