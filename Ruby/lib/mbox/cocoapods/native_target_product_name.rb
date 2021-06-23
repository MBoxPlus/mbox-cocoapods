
module Xcodeproj
  class Project
    module Object
      class PBXNativeTarget < AbstractTarget
        def link_product_name
          pname = common_resolved_build_setting("PRODUCT_NAME").dup
          pname.gsub!(/\$[{|\(]?PROJECT_NAME[}|\)]?/, project.name)
          pname.gsub!(/\$[{|\(]?TARGET_NAME[}|\)]?/, name)
        end

        def output_product_name
          if symbol_type == :static_library
            prefix = 'lib'
          end
          extension = Constants::PRODUCT_UTI_EXTENSIONS[symbol_type]
          "#{prefix}#{link_product_name}.#{extension}"
        end
      end
    end
  end
end
