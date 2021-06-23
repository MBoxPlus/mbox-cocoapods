
# 静态 SDK 不需要 link Pods.a
module Pod
    class Installer
        class UserProjectIntegrator
            class TargetIntegrator
                alias_method :ori_add_pods_library, :add_pods_library
                def add_pods_library
                    ori_add_pods_library
                    frameworks = user_project.frameworks_group
                    native_targets.each do |native_target|
                        next unless native_target.static?
                        # 只有静态库不 link，其他类型都需要
                        build_phase = native_target.frameworks_build_phase
                        new_product_ref = frameworks.files.find { |f| f.path == target.product_name }
                        if new_product_ref
                            build_phase.remove_file_reference(new_product_ref)
                            new_product_ref.remove_from_project
                        end
                    end
                end
            end
        end
    end
end
