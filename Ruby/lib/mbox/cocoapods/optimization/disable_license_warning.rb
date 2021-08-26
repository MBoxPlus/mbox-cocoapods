
module Pod
  module Generator
    class Acknowledgements
      # Replace origin method
      alias_method :mbox_license_text_0709, :license_text
      def license_text(spec)
        return nil unless spec.license
        text = spec.license[:text]
        unless text
          if license_file = spec.license[:file]
            license_path = file_accessor(spec).root + license_file
            if File.exist?(license_path)
              text = IO.read(license_path)
            end
          elsif license_file = file_accessor(spec).license
            text = IO.read(license_file)
          end
        end
        text
      end
    end
  end
end
