
require_relative "dependency"
module Pod
  class Resolver
    alias mbox_search_for_520 search_for
    def search_for(dependency)
      name = dependency.name
      dep = ::MBox::Dependency.all[dependency.root_name]
      if dep
        new_dependency = dep.to_dependency
        new_dependency.name = name
        UI.message "[MBox] Redirect #{dependency} -> #{new_dependency}"
        dependency = new_dependency
      end
      mbox_search_for_520(dependency)
    end
  end
end
