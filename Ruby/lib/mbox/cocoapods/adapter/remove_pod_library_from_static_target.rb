
module Pod
  class Installer
    class UserProjectIntegrator
      class TargetIntegrator
        alias_method :mbox_pod_add_pods_library_0112, :add_pods_library
        def add_pods_library
          mbox_pod_add_pods_library_0112
          frameworks = user_project.frameworks_group
          native_targets.each do |native_target|
            next unless native_target.static?

            build_phase = native_target.frameworks_build_phase
            new_product_ref = frameworks.files.find {|f| f.path == target.product_name}

            next unless new_product_ref

            # Remove Link Pods.a for static library
            build_phase.remove_file_reference(new_product_ref)
            new_product_ref.remove_from_project
          end
        end
      end
    end
  end
end
