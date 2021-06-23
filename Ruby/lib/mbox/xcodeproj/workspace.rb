
module Xcodeproj
    class Workspace
        attr_accessor :path

        alias_method :ori_load_schemes, :load_schemes
        def load_schemes(workspace_dir_path)
            @path = workspace_dir_path
            ori_load_schemes(workspace_dir_path)
        end

        def user_schemes
            @user_schemes ||= (XCScheme.user_data_dir(@path) + '*.xcscheme').children.map { |path| File.basename(path, ".*") => path }.inject(:merge)
        end

        def shared_schemes
            @shared_schemes ||= (XCScheme.shared_data_dir(@path) + '*.xcscheme').children.map { |path| File.basename(path, ".*") => path }.inject(:merge)
        end

        def scheme_dir(shared = false)
            if shared
                XCScheme.shared_data_dir(@path)
            else
                XCScheme.user_data_dir(@path)
            end
        end

        def scheme_manager(shared = false)
            (shared ? @shared_scheme_manager : @user_scheme_manager) ||= begin
                path = scheme_dir(shared) + 'xcschememanagement.plist'
                if path.exist?
                    Plist.parse_xml(path.to_s)
                else
                    nil
                end
            end
        end

        def create_scheme_manager(shared = false)
            return @scheme_manager(shared) if @scheme_manager(shared)

            xcschememanagement = {}
            xcschememanagement['SchemeUserState'] = {}
            xcschememanagement['SuppressBuildableAutocreation'] = {}

            xcschememanagement_path = scheme_dir(shared) + 'xcschememanagement.plist'
            Plist.write_to_path(xcschememanagement, xcschememanagement_path)
            @scheme_manager(shared)
        end

        def save_scheme_manager(shared = false)
            Plist.write_to_path(scheme_manager(shared), (scheme_dir(shared) + 'xcschememanagement.plist').to_s)
        end

        def create_scheme(name, visible = true, shared = false)
            schemes = shared ? @shared_schemes : @user_schemes
            return XCScheme.new(schemes[name]) if schemes[name]

            scheme = XCScheme.new
            yield scheme if block_given?
            scheme.save_as(@path, name, shared)

            manager = create_scheme_manager(shared)

            manager['SchemeUserState']["#{name}.xcscheme"] = {}
            manager['SchemeUserState']["#{name}.xcscheme"]['isShown'] = visible
            save_scheme_manager(shared)
            scheme
        end

        def remove_scheme(name, shared = false)
            schemes = shared ? @shared_schemes : @user_schemes
            path = schemes[name]
            if path
                FileUtils.rm_rf path
                save_scheme_manager(shared)
            end
        end
    end
end
