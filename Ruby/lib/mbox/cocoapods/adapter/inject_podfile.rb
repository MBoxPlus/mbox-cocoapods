
module Pod
  class Project < Xcodeproj::Project
    alias_method :mbox_add_podfile_1018, :add_podfile
    def add_podfile(podfile_path)
      # Do NOT add the Podfile into Pods project. It is gerenated by MBox.
      # mbox_add_podfile_1018(podfile_path)
    end
  end

  class Installer
    class Xcode
      class PodsProjectGenerator
        def inject_multi_podfiles(project)
          return unless project
          podfiles = Config.instance.podfile.sub_files
          unless podfiles.blank?
            group = project.new_group("_Podfiles")
            podfiles.each do |name, file|
              next if Config.instance.podfile_path.nil?
              group_path = Config.instance.podfile_path.dirname + name
              g = group.new_group(name, group_path)
              ref = g.new_reference(file)
              g.set_path(group_path.realpath) if group_path.exist?
              project.mark_ruby_file_ref(ref)
            end
          end
        end
      end

      class SinglePodsProjectGenerator
        alias_method :mbox_generate_1018!, :generate!
        def generate!
          result = mbox_generate_1018!
          inject_multi_podfiles(result.project)
          result
        end
      end

      class MultiPodsProjectGenerator
        alias_method :mbox_geneerate_1018!, :generate!
        def generate!
          result = mbox_geneerate_1018!
          inject_multi_podfiles(result.project)
          result
        end
      end
    end
  end
end
