
require "mbox/config/json_helper"

module MBox
  class Dependency
    include JSONable

    attr_accessor :name
    attr_accessor :version
    attr_accessor :source
    attr_accessor :git
    attr_accessor :commit
    attr_accessor :tag
    attr_accessor :branch
    attr_accessor :targets # [String]
    attr_accessor :configurations # {String => [String]}
    attr_accessor :path
    attr_accessor :podspec
    
    def requirements(target)
      result = external_source
      result[:source] = source if source
      result[:configurations] = configurations[target] if configurations
      result
    end

    def root_name
      name.split("/").first
    end

    def git
      return if @git.blank?
      @git
    end

    def source
      return if @source.blank?
      @source
    end

    def path
      return if @path.blank?
      @path
    end

    def podspec
      return if @podspec.blank?
      @podspec
    end

    def external_source?
      remote_source? || local_source?
    end

    def remote_source?
      !git.blank? || !podspec.blank?
    end

    def local_source?
      !path.blank?
    end

    def external_source
      result = {}
      if git
        result[:git] = git
        if commit
          result[:commit] = commit
        elsif branch
          result[:branch] = branch
        end
        result[:tag] = tag if tag
      end

      if path
        result[:path] = path
      end

      if podspec
        result[:podspec] = podspec
      end

      result = nil if result.blank?
      result
    end

    def to_s
      "#{name}" + " " + (external_source? ? "#{external_source}" : "(#{version})")
    end

    def to_dependency
      if remote_source?
        key = [:commit, :tag, :branch].select { |method| send(method) }.first
        value = send(key) if key
        ::Pod::Dependency.new(name, {:git => git, key => value})
      elsif local_source?
        ::Pod::Dependency.new(name, {:path => path})
      else
        dependency = ::Pod::Dependency.new(name, version)
        dependency.podspec_repo = source
        dependency
      end
    end

    def self.from_dependency(other, root:false)
      dependency = nil
      if other.is_a? ::Pod::Dependency
        dependency = self.new
        dependency.name = other.name
        dependency.version = other.requirement.requirements.first.last.version if other.requirement.exact?
        dependency.source = other.podspec_repo
        if other.external?
          dependency.git = other.external_source[:git]
          dependency.commit = other.external_source[:commit]
          dependency.tag = other.external_source[:tag]
          dependency.branch = other.external_source[:branch]
          dependency.path = other.external_source[:path]
          dependency.podspec = other.external_source[:podspec]
        end
      elsif other.is_a? Dependency
        dependency = from_object(other.to_h)
      end
      dependency.name = dependency.root_name if dependency && root
      dependency
    end

    def ==(other)
      other.is_a?(self.class) &&
        name == other.name &&
        version == other.version &&
        external_source_equal?(other) &&
        source == other.source
    end

    def external_source_equal?(other)
      other.is_a?(self.class) &&
        git == other.git &&
        branch == other.branch &&
        _commit_equal?(other.commit) &&
        tag == other.tag &&
        path == other.path &&
        podspec == other.podspec
    end

    def _commit_equal?(_commit)
      return true if commit == _commit
      if commit && _commit
        _commit[0...[8, _commit.length].min] == \
          commit[0...[8, commit.length].min]
      else
        false
      end
    end

    def self.all
      @all ||= begin
        info = ENV["MBOX_COCOAPODS_DEPENDENCIES"]
        return {} if info.blank?
        require 'json'
        json = JSON.parse(info)
        raise "Parse JSON Failed! `#{info}`" if json.nil?
        json.map do |name, info|
          dep = self.from_json_object(info)
          dep.name = name
          [dep.root_name, dep]
        end.to_h
      end
    end
  end
end
