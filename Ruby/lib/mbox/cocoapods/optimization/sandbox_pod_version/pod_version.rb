module Pod
  class VersionFile
    attr_accessor :version
    attr_accessor :spec

    def initialize(hash)
      self.version = hash['VERSION']
      self.spec = hash['SPEC']
    end

    def update(specification)
      self.version = specification.version.to_s
      self.spec = specification.checksum
    end

    def save_as(directory)
      self.class.save_hash(directory, {
        :VERSION => spec.version.to_s,
        :SPEC => spec.checksum
      })
    end

    def ==(other)
      return false if other.nil?
      if other.is_a?(Specification)
        version == other.version.to_s &&
        spec = other.checksum
      elsif other.is_a?(VersionFile)
        version == other.version &&
        spec == other.spec
      else
        false
      end
    end

    class << self

      def path_in_directory(directory)
        directory + '.pod_version'
      end

      def from_file(path)
        return nil unless path.exist?
        hash = JSON.parse(File.read(path))
        return nil unless hash && hash.is_a?(Hash)
        self.new(hash)
      rescue
        nil
      end

      def save_specification(directory, specification)
        save_hash(directory, {
          :VERSION => specification.version.to_s,
          :SPEC => specification.checksum
        })
      end

      def save_hash(directory, hash)
        File.write(path_in_directory(directory), hash.to_json)
      end

    end
  end
end
