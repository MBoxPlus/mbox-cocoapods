module Pod
  class Config
    attr_accessor :update_mode
  end

  class Command
    class Update < Command
      alias_method :mbox_run_1108, :run
      def run
        if @pods
          config.update_mode = @pods
        else
          config.update_mode = :all
        end
        mbox_run_1108
      end
    end

    module Install_MBoxDoNotUpdateLockedPod
      def run
        config.update_mode = nil
        super
      end
    end
    Install.prepend(Install_MBoxDoNotUpdateLockedPod)
  end

  class Resolver
    include Config::Mixin

    alias_method :mbox_specifications_for_dependency_1108, :specifications_for_dependency
    def specifications_for_dependency(dependency, additional_requirements = [])
      r = mbox_specifications_for_dependency_1108(dependency, additional_requirements)
      if config.update_mode.nil? || 
        (config.update_mode.is_a?(Array) && !config.update_mode.include?(Specification.root_name(dependency.name)))
        locked = config.lockfile.version(dependency.name)
        if locked
          prefect_index = r.rindex { |s| locked == s.version }
          if prefect_index
            prefect = r[prefect_index]
            r.delete_at(prefect_index)
            r.append(prefect)
          end
        end
      end
      r
    end
  end
end
