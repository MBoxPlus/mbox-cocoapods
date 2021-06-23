
module Pod
  class Sandbox
    alias_method :mbox_pod_initialize_0304, :initialize
    def initialize(root)
      mbox_pod_initialize_0304(root)
      @root = Pathname.new(root).cleanpath
    end
    # Returns the path where the Pod with the given name is stored
    # within the Sandbox. Does not account for where local pods are stored.
    # It maybe a symlink directory.
    #
    # @param  [String] name
    #         The name of the Pod.
    #
    # @return [Pathname] the path of the Pod.
    #
    def pod_relative_dir(name)
      Pathname.new(Specification.root_name(name))
    end

    alias_method :pod_realdir, :pod_dir
    # Returns the path where the Pod with the given name is stored
    # within the Sandbox. Does not account for where local pods are stored.
    # It maybe a symlink directory.
    #
    # @param  [String] name
    #         The name of the Pod.
    #
    # @return [Pathname] the path of the Pod.
    #
    def pod_dir_in_sandbox(name)
      sources_root + pod_relative_dir(name)
    end

  end

  # class Project
  #   alias_method :mbox_pod_add_pod_group_0304, :add_pod_group
  #   def add_pod_group(pod_name, path, development = false, absolute = false)
  #     # path = path.realpath if development
  #     mbox_pod_add_pod_group_0304(pod_name, path, development, absolute)
  #   end
    # 以下方法覆盖原生方法
    # def add_file_reference(absolute_path, group, reflect_file_system_structure = false, base_path = nil)
    #   file_path_name = absolute_path.is_a?(Pathname) ? absolute_path : Pathname(absolute_path)
    #   if ref = reference_for_path(file_path_name)
    #     return ref
    #   end

    #   group = group_for_path_in_group(file_path_name, group, reflect_file_system_structure, base_path)
    #   ref = group.new_file(file_path_name.cleanpath)
    #   @refs_by_absolute_path[file_path_name.to_s] = ref
    # end

    # # 以下方法覆盖原生方法
    # def reference_for_path(absolute_path)
    #   absolute_path = absolute_path.is_a?(Pathname) ? absolute_path : Pathname(absolute_path)
    #   unless absolute_path.absolute?
    #     raise ArgumentError, "Paths must be absolute #{absolute_path}"
    #   end

    #   refs_by_absolute_path[absolute_path.to_s] ||= refs_by_absolute_path[absolute_path.cleanpath.to_s]
    # end

    # 以下方法覆盖原生方法
    # def group_for_path_in_group(absolute_pathname, group, reflect_file_system_structure, base_path = nil)
    #   unless absolute_pathname.absolute?
    #     raise ArgumentError, "Paths must be absolute #{absolute_pathname}"
    #   end
    #   unless base_path.nil? || base_path.absolute?
    #     raise ArgumentError, "Paths must be absolute #{base_path}"
    #   end

    #   relative_base = base_path || group.real_path
    #   relative_pathname = absolute_pathname.relative_path_from(relative_base)
    #   relative_dir = relative_pathname.dirname

    #   # Add subgroups for directories, but treat .lproj as a file
    #   if reflect_file_system_structure
    #     path = relative_base
    #     relative_dir.each_filename do |name|
    #       break if name.to_s.downcase.include? '.lproj'
    #       next if name == '.'
    #       # Make sure groups have the correct absolute path set, as intermittent
    #       # directories may not be included in the group structure
    #       path += name
    #       group = group.children.find { |c| c.display_name == name } || group.new_group(name, path)
    #     end
    #   end

    #   # Turn files inside .lproj directories into a variant group
    #   if relative_dir.basename.to_s.downcase.include? '.lproj'
    #     group_name = variant_group_name(absolute_pathname)
    #     lproj_parent_dir = absolute_pathname.dirname.dirname
    #     group = @variant_groups_by_path_and_name[[lproj_parent_dir, group_name]] ||=
    #               group.new_variant_group(group_name, lproj_parent_dir)
    #   end

    #   group
    # end
  # end

  class PodTarget
    alias_method :mbox_pod_framework_paths_0226, :framework_paths
    def framework_paths
      @framework_paths ||= begin
        hash = mbox_pod_framework_paths_0226
        file_accessors.each do |file_accessor|
          frameworks = hash[file_accessor.spec.name]
          root = file_accessor.root.realpath
          frameworks.map! do |framework|
            source_path = relative_path_to_sandbox(file_accessor.spec.name, root, framework.source_path)
            dsym_path = relative_path_to_sandbox(file_accessor.spec.name, root, framework.dsym_path)
            if Gem::Version.new(Pod::VERSION) < Gem::Version.new("1.9")
              FrameworkPaths.new(source_path, dsym_path)
            else
              Xcode::FrameworkPaths.new(source_path, dsym_path)
            end
          end
        end
        hash
      end
    end

    alias_method :mbox_pod_resource_paths_0226, :resource_paths
    def resource_paths
      @resource_paths ||= begin
        hash = mbox_pod_resource_paths_0226
        file_accessors.each do |file_accessor|
          resource_paths = hash[file_accessor.spec.name]
          resource_paths.map! do |resource_path|
            relative_path_to_sandbox(file_accessor.spec.name, file_accessor.root, resource_path)
          end
        end
        hash
      end
    end

  #   # 以下方法覆盖原生方法
  #   def pod_target_srcroot
  #     "${PODS_ROOT}/#{sandbox.pod_realdir(pod_name).relative_path_from(sandbox.root)}"
  #   end
  #   # Get the relative path from the Pod Directory in sandbox directory.
    
    # @param [Sandbox::FileAccessor] file_accessor @see #file_accessors
    # @param [Pathname] The Pathname from the file_accessor
    
    # @return [String] Like "PodName/path"
    def relative_path_to_sandbox(pod_name, root, path)
      return path if path.nil?
      return path unless path.start_with?("${PODS_ROOT}/")
      path = path["${PODS_ROOT}/".length..-1]
      path = (sandbox.root + path).realpath.relative_path_from(root)
      "${PODS_ROOT}/" + (sandbox.pod_relative_dir(pod_name) + path).to_s
    end
  end

  class Installer
    class Analyzer
      class SandboxAnalyzer
        alias_method :mbox_pod_pod_added?, :pod_added?
        def pod_added?(pod)
          return true if mbox_pod_pod_added?(pod)
          return false unless sandbox.local?(pod)
          poddir = sandbox.pod_dir_in_sandbox(pod)
          return true unless poddir.symlink?
          return true unless poddir.exist?
          return poddir.realpath != sandbox.pod_realdir(pod)
        end
      end
    end

    class PodSourceInstaller
      alias_method :mbox_pod_install_0303!, :install!
      def install!
        link_source if local?
        mbox_pod_install_0303!
      end

      # Create a symlink at `$PODS_ROOT/#{POD_NAME}` to the path of the local pod,
      # making the local pod's files available at `${PODS_ROOT}/#{POD_NAME}`
      #
      # @return [void]
      #
      def link_source
        poddir = sandbox.pod_dir_in_sandbox(name)
        realdir = sandbox.pod_realdir(name)
        unless sandbox.local_path_was_absolute?(name)
          realdir = realdir.realpath.relative_path_from(poddir.dirname.realpath)
        end
        UI.message "Linking #{UI.path poddir} -> `#{realdir}`", '> ' do
          if poddir.exist? || poddir.symlink?
            FileUtils.rm_r(poddir)
          end
          File.symlink(realdir, poddir)
        end
      end
    end
  end

  class Target
    class BuildSettings
      class PodTargetSettings
        # 覆盖原生方法
        define_build_settings_method :vendored_framework_search_paths, :memoized => true do
          search_paths = []
          search_paths.concat(file_accessors.flat_map do |file_accessor|
            root = file_accessor.root.realpath
            file_accessor.vendored_frameworks.map do |f|
              relative_path = f.realpath.relative_path_from(root).dirname.to_s
              if relative_path == "."
                File.join('${PODS_ROOT}', Specification.root_name(file_accessor.spec.name))
              elsif relative_path.start_with?("..")
                File.join('${PODS_ROOT}', f.dirname.relative_path_from(target.sandbox.root))
              else
                File.join('${PODS_ROOT}', Specification.root_name(file_accessor.spec.name), relative_path)
              end
            end
          end)

          if PodTarget.method_defined? :xcframeworks
            xcframework_intermediates = vendored_xcframeworks.
              select { |xcf| xcf.build_type.framework? }.
              map { |xcf| BuildSettings.xcframework_intermediate_dir(xcf) }.
              uniq
            search_paths.concat xcframework_intermediates
          end
          search_paths

        end
      end
    end
  end
end
