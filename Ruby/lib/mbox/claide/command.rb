
require 'claide/command'

module CLAide
  class Command
    alias_method :mbox_pod_initialize, :initialize
    def initialize(argv)
      mbox_pod_initialize(argv)
      Command.ansi_output = @ansi_output if @ansi_output
    end
  end
end
