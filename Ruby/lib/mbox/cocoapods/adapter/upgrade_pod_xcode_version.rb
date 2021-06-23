# Upgrade Pods project format to Xcode 9.3-compatible from 3.2-compatible

module PodsProjectUpgrade
    def redef_without_warning(const, value)
        self.class.send(:remove_const, const) if self.class.const_defined?(const)
        self.class.const_set(const, value)
    end
    def self.included(mod)
        # mod::DEFAULT_OBJECT_VERSION = 50
        const = "DEFAULT_OBJECT_VERSION"
        mod.send(:remove_const, const) if mod.const_defined?(const)
        mod.const_set(const, 50)
    end
end
Xcodeproj::Constants.send(:include, PodsProjectUpgrade)
