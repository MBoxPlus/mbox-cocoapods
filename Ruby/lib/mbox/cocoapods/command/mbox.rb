

module Pod
  class Command
    class Mbox < Command
      require 'mbox/cocoapods/command/dependencies.rb'
      require 'mbox/cocoapods/command/spec.rb'

      self.summary = 'MBox support'
      self.description = 'Lists all available pods.'

      def self.options
        [
        ].concat(super)
      end

      def initialize(argv)
        super
      end
    end
  end
end
