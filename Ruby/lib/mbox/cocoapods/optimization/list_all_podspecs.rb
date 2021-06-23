
# 列出所有用到的 podspec，生成 sublime project 文件，方便查看
module Pod
  class Installer
    class Analyzer
      alias_method :mbox_pod_specs_analyze, :analyze
      def analyze(allow_fetches = true)
        mbox_pod_specs_analyze(allow_fetches).tap do |result|
          sublime = {
            "folders": result.specifications.map { |s| s.root }.uniq(&:name).map { |spec|
              {
                "path": spec.defined_in_file.dirname,
                "name": spec.name,
                "folder_exclude_patterns": ["**/**"],
                "file_include_patterns": [spec.defined_in_file.basename]
              }
            }
          }
          File.write(@podfile.defined_in_file.dirname + "podspecs.sublime-project", JSON.pretty_generate(sublime))
        end
      end
    end
  end
end
