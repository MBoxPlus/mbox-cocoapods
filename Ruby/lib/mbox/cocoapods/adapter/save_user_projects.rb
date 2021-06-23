
module Pod
  class Installer
    class Analyzer
      alias_method :ori_inspect_targets_to_integrate, :inspect_targets_to_integrate
      def inspect_targets_to_integrate
        inspection_result = ori_inspect_targets_to_integrate
        MBox::Config.instance.user_projects ||= inspection_result.values.map(&:project).uniq
        inspection_result
      end
    end
  end
end
