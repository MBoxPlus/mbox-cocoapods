
module Xcodeproj
    class Project
        def name
            @name ||= path.basename(".*").to_s
        end
    end
end

module MBox
    class Config
        include JSONable
        #-------------------------------------------------------------------------#

        attr_accessor :user_projects
        def user_project(name)
            value = user_targets(name)
            return nil if value.blank?
            return value[0]
        end

        # return (project, [targets]) or nil
        def user_targets(name)
            return nil if user_projects.blank?

            @user_targets_hash ||= {}
            value = @user_targets_hash[name]
            if value
                return value == :null ? nil : value
            end

            target_names = nil
            current_feature.repos.each { |repo| 
                if names = repo.pod_targets_by_name(name)
                    target_names = names
                    break
                end
            }
            target_names ||= [Pod::Specification.root_name(name)]

            user_projects.each do |project|
                targets = self.user_targets_in_project(target_names, project)
                unless targets.blank?
                    @user_targets_hash[name] = [project, targets]
                    return [project, targets]
                end
            end

            @user_targets_hash[name] = :null
            nil
        end

        def user_targets_in_project(names, project)
            targets = project.targets.select { |target|
                target.is_a?(::Xcodeproj::Project::Object::PBXNativeTarget) &&
                [:framework, :dynamic_library, :static_library].include?(target.symbol_type)
            }
            targets = names.map do |name|
                targets.find { |target| target.name == name }
            end.compact
            return nil if targets.blank?
            targets
        end

        # {pod_name: repo}
        def development_repos
            @development_repos ||= begin
                hash = current_feature.repos.map { |repo| [repo.pod_name, repo] }.to_h
                hash.delete(nil)
                hash
            end
        end

        def development_pods
            @development_pods ||= begin
                hash = {}
                unless current_feature.repos.blank?
                    current_feature.repos.each do |repo|
                        repo.podspec_paths.each do |name, spec_path|
                            active_components = repo.active_components
                            if active_components.nil? || active_components.include?(name)
                                Pod::UI.info "[MBox] Redirect component `#{name}` -> #{Pod::UI.path(spec_path.dirname)}"
                                hash[name] = spec_path
                            else
                                Pod::UI.info "[MBox] Ignore component `#{name}`"
                            end
                        end
                    end
                end
                hash
            end
        end

    end
end
