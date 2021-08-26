
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
            return nil if user_projects.blank?
            name = Pod::Specification.root_name(name)
            user_projects.find{ |project|
                project.targets.any? { |target|
                    target.name == name &&
                    target.is_a?(::Xcodeproj::Project::Object::PBXNativeTarget) &&
                    [:framework, :dynamic_library, :static_library].include?(target.symbol_type) 
                }
            }
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
