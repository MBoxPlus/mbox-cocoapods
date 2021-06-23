
# 清理 Workspace 中不存在的项目
module Pod
  class Installer
    class UserProjectIntegrator
      alias_method :mbox_pod_create_workspace_0305, :create_workspace
      def create_workspace
        mbox_pod_create_workspace_0305
        workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
        clean = false
        workspace.document.get_elements('/Workspace//FileRef').each do |node|
          ref = Xcodeproj::Workspace::FileReference.from_node(node)
          path = Pathname.new(ref.absolute_path(workspace_path.dirname))
          if !path.exist? || (path.extname.downcase == '.xcodeproj' && !(path + "project.pbxproj").exist?)
            workspace.document.root.delete(node)
            clean = true
          end
        end
        workspace.save_as(workspace_path) if clean
      end
    end
  end
end
