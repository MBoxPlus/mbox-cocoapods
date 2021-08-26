
module Xcodeproj
  class Project
    module Object
      class PBXNativeTarget
        def static?
          if symbol_type == :framework
            common_resolved_build_setting("MACH_O_TYPE") == 'staticlib'
          else
            symbol_type == :static_library
          end
        end

        def dynamic?
          if symbol_type == :framework
            common_resolved_build_setting("MACH_O_TYPE") == 'mh_dylib'
          else
            symbol_type == :dynamic_library
          end
        end
      end
    end
  end
end
