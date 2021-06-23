
module Xcodeproj
  class XCScheme
    class BuildAction < XMLElementWrapper
      def clear_entries
        @xml_element.elements.delete_all('BuildActionEntries')
      end
    end

    class BuildableReference < XMLElementWrapper
      def container_path
        container = @xml_element.attributes['ReferencedContainer']
        container.sub(/.*?:/, "") if container
      end

      def container_path=(path)
        @xml_element.attributes['ReferencedContainer'] = "container:#{path}"
      end
    end
  end
end

module Pod
  class Installer
    class UserProjectIntegrator
      alias_method :mbox_pod_create_workspace_0306, :create_workspace
      def create_workspace
        mbox_pod_create_workspace_0306
        all_projects = MBox::Config.instance.user_projects.sort_by(&:name).map(&:path).push(sandbox.project_path).uniq
        file_references = all_projects.map do |path|
          relative_path = path.relative_path_from(workspace_path.dirname).to_s
          Xcodeproj::Workspace::FileReference.new(relative_path, 'group')
        end

        workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
        new_file_references = file_references - workspace.file_references
        unless new_file_references.empty?
          new_file_references.each { |fr| workspace << fr }
          # create_schemes(workspace_path)
          workspace.save_as(workspace_path)
        end
      end

      def schemes_in_path(path)
        schemes = Dir[(Xcodeproj::XCScheme.shared_data_dir(path) + '*.xcscheme').to_s].map do |scheme|
          [File.basename(scheme, '.xcscheme'), scheme]
        end.to_h
        schemes
      end

      def user_target_dependencies
        @dependency_targets ||= begin
          dependency_targets = {}
          targets.each do |aggregate_target|
            dep_targets = aggregate_target.pod_targets.map(&:user_targets).flatten.compact.uniq
            unless dep_targets.blank?
              aggregate_target.user_targets.each do |user_target|
                dependency_targets[user_target] = dep_targets
              end
            end
          end
          dependency_targets.each do |user_target, dependencies|
            user_target.dependencies.map(&:target).each do |dep_target|
              deps = dependency_targets[dep_target]
              dependencies.concat(deps).uniq! unless deps.blank?
            end
          end
          dependency_targets
        end
      end

      def create_schemes(workspace_path)
        workspace_scheme_dir = Xcodeproj::XCScheme.shared_data_dir(workspace_path)
        FileUtils.mkdir_p(workspace_scheme_dir)
        workspace_schemes = schemes_in_path(workspace_path)
        MBox::Config.instance.user_projects.each do |project|
          schemes_in_path(project.path).each do |name, path|
            mbox_scheme_name = "#{name} (MBox)"
            mbox_scheme_path = workspace_schemes[mbox_scheme_name]
            scheme = if mbox_scheme_path.nil?
              mbox_scheme_path = File.join(workspace_scheme_dir, "#{mbox_scheme_name}.xcscheme")
              FileUtils.cp(path, mbox_scheme_path)
              Xcodeproj::XCScheme.new(mbox_scheme_path).tap do |scheme|
                # 关闭并行编译
                scheme.build_action.parallelize_buildables = false

                # 更新相对路径
                refs = []
                refs.concat scheme.build_action.entries.map(&:buildable_references).flatten
                [scheme.test_action, scheme.launch_action, scheme.profile_action].each do |action|
                  refs.concat action.xml_element.get_elements('MacroExpansion').map { |node| Xcodeproj::XCScheme::MacroExpansion.new(node) }.map(&:buildable_reference)
                  runable = action.xml_element.elements['BuildableProductRunnable']
                  refs << Xcodeproj::XCScheme::BuildableProductRunnable.new(runable, 0).buildable_reference if runable
                end
                project_dir = project.path.dirname
                workspace_dir = workspace_path.dirname
                refs.each do |ref|
                  path = project_dir + ref.container_path
                  path = path.relative_path_from(workspace_dir)
                  ref.container_path = path.to_s
                end
              end
            else
              Xcodeproj::XCScheme.new(mbox_scheme_path)
            end

            main_entry = scheme.build_action.entries.last
            main_target = user_target_dependencies.keys.find { |user_target| user_target.uuid == main_entry.buildable_references.first.target_uuid }

            dependency_targets = user_target_dependencies[main_target]
            entries = (dependency_targets || []).map do |user_target|
              Xcodeproj::XCScheme::BuildAction::Entry.new(user_target).tap do |entry|
                entry.build_for_testing = true
                entry.build_for_running = true
                entry.build_for_profiling = true
                entry.build_for_archiving = true
                entry.build_for_analyzing = true
                # 更新相对路径，Xcodeproj 不支持直接设置路径
                path = user_target.project.path.relative_path_from(workspace_path.dirname)
                ref = entry.buildable_references.first
                ref.container_path = path
                ref.buildable_name = user_target.output_product_name
              end
            end
            entries << main_entry

            scheme.build_action.clear_entries
            entries.each do |entry|
              scheme.build_action.add_entry(entry)
            end
            scheme.save!
          end
        end
      end
    end
  end
end
