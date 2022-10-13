
module Xcodeproj
  class Project
    module Object
      class PBXNativeTarget < AbstractTarget
        def link_product_name
          pname = common_resolved_build_setting("PRODUCT_NAME")
          v = pname.match /\$\((\w+)(:([\w:]+))?\)/
          return pname if v.nil?
          key = v[1]
          case key
          when "PROJECT_NAME"
            pname = project.name
          when "TARGET_NAME"
            pname = name
          else
            return pname
          end
          return pname if v[3].nil?
          v[3].split(":").each do |transform|
            case transform
            when "c99extidentifier"
              pname = pname.gsub(" ", "_")
            when "rfc1034identifier"
              pname = pname.gsub(" ", "-")
            when "lower"
              pname = pname.downcase
            when "upper"
              pname = pname.upcase
            end
          end
          return pname
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
