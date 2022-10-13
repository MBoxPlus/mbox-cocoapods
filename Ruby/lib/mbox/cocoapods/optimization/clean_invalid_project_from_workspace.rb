
# Clean non-exist projects in workspace
module Pod
  class Installer
    class UserProjectIntegrator
      alias_method :mbox_pod_create_workspace_0305, :create_workspace
      def create_workspace
        mbox_pod_create_workspace_0305
        workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
        clean = clean_nonexist_projects(workspace)
        sort = sort_projects(workspace)
        workspace.save_as(workspace_path) if clean || sort
      end

      def clean_nonexist_projects(workspace)
        clean = false
        workspace.file_references.each do |ref|
          path = Pathname.new(ref.absolute_path(workspace_path.dirname))
          if !path.exist? || (path.extname.downcase == '.xcodeproj' && !(path + "project.pbxproj").exist?)
            workspace.delete_reference(ref)
            clean = true
          end
        end
        clean
      end

      def sort_projects(workspace)
        refs = workspace.file_references
        refs2 = refs.sort { |a, b| 
          File.basename(a.path) <=> File.basename(b.path)
        }
        return false if refs == refs2
        refs.each do |ref|
          workspace.delete_reference(ref)
        end
        refs2.each do |ref|
          workspace << ref
        end
        true
      end
    end
  end
end

module Xcodeproj
  class Workspace
    def delete_reference(ref)
      @document.elements.delete("/Workspace//FileRef[@location='#{ref.type}:#{ref.path}']")
    end
  end
end
