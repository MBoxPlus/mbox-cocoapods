
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

require 'mbox/cocoapods/native_target_is_static_library.rb'
require 'mbox/cocoapods/native_target_product_name.rb'

# require 'mbox/cocoapods/adapter/replace_ui_and_cli_module.rb'

############################## Adapter ##############################
# 下面的 Hook 会替换原生逻辑，因此要提前加载
require "mbox/cocoapods/adapter/allow_duplicate_pod.rb"
require "mbox/cocoapods/optimization/disable_license_warning.rb"

############################## BugFix ##############################
#require "mbox/cocoapods/bugfix/remove_configuration_from_aggregate_target.rb"

require "mbox/cocoapods/bugfix/reject_copy_resource_for_static_framework.rb"

############################## Adapter ##############################
require "mbox/cocoapods/adapter/save_user_projects.rb"
require "mbox/cocoapods/adapter/disable_development_pods.rb"
require "mbox/cocoapods/adapter/link_development_pods.rb"
require "mbox/cocoapods/adapter/load_mbox_podfile.rb"
require "mbox/cocoapods/adapter/write_mbox_lockfile.rb"
require "mbox/cocoapods/adapter/shadow_sandbox.rb"
# require "mbox/cocoapods/adapter/upgrade_pod_xcode_version.rb"
# require "mbox/cocoapods/adapter/integrate_copy_framework_resource_script.rb"
# require "mbox/cocoapods/adapter/save_user_workspace.rb"
require "mbox/cocoapods/adapter/inject_podfile.rb"
require "mbox/cocoapods/adapter/multi_project.rb"
require "mbox/cocoapods/adapter/multi_platform.rb"
require "mbox/cocoapods/adapter/multi_hook.rb"
require "mbox/cocoapods/adapter/multi_install_options.rb"
# require "mbox/cocoapods/adapter/link_local_pod_path.rb"
require "mbox/cocoapods/adapter/disable_sandbox_cleaner.rb"
require "mbox/cocoapods/adapter/disable_pod_dir_cleaner.rb"
require "mbox/cocoapods/adapter/convert_develop_aggregate_target_to_pod_target.rb"
require "mbox/cocoapods/adapter/all_dependencies.rb"

require "mbox/cocoapods/adapter/command/lib/lint.rb"

require "mbox/cocoapods/adapter/dependency_change/resolver.rb"
require "mbox/cocoapods/adapter/dependency_change/analyzer.rb"
require "mbox/cocoapods/adapter/dependency_change/lockfile.rb"
############################## Optimization ##############################
require "mbox/cocoapods/optimization/list_all_podspecs.rb"
require "mbox/cocoapods/optimization/do_not_update_locked_pod.rb"
require "mbox/cocoapods/optimization/clean_invalid_project_from_workspace.rb"
require "mbox/cocoapods/optimization/convert_source_from_git_to_http.rb"

# sandbox_pod_version
require "mbox/cocoapods/optimization/sandbox_pod_version/pod_version.rb"
require "mbox/cocoapods/optimization/sandbox_pod_version/pod_source_preparer.rb"
require "mbox/cocoapods/optimization/sandbox_pod_version/sandbox_analyzer.rb"

# use cocoapods optimize
cocoapods_optimize = Bundler.rubygems.find_name('cocoapods-optimize').first
unless cocoapods_optimize && cocoapods_optimize.version >= Gem::Version.new('2.1.0')
  require "mbox/cocoapods/optimization/remove_link_pods_library@.rb"
  require "mbox/cocoapods/optimization/clean_target_dependencies@.rb"
  require "mbox/cocoapods/optimization/wire_bundle_target_dependencies@.rb"
  require "mbox/cocoapods/optimization/auto_update_repo@.rb"
  require "mbox/cocoapods/bugfix/replace_unzip_with_ditto@.rb"
end

require "mbox/cocoapods/optimization/multi_download.rb"
