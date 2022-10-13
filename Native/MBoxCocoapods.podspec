
require 'yaml'
yaml = YAML.load_file('../manifest.yml')
name = yaml["NAME"]
name2 = name.sub('MBox', 'mbox').underscore
version = ENV["VERSION"] || yaml["VERSION"]

Pod::Spec.new do |spec|
  spec.name         = "#{name}"
  spec.version      = "#{version}"
  spec.summary      = "CocoaPods Support Plugin for MBox."
  spec.description  = <<-DESC
    Make mbox to support cocoapods.
                   DESC

  spec.homepage     = "https://github.com/MBoxPlus/#{name2}"

  spec.license      = "MIT"
  spec.author       = { `git config user.name`.strip => `git config user.email`.strip }
  spec.source       = { :git => "git@github.com/MBoxPlus/#{name2}.git", :tag => "#{spec.version}" }

  spec.platform = :osx, '10.15'

  spec.source_files = "#{name}/*.{h,m,swift}", "#{name}/**/*.{h,m,swift}"

  yaml['DEPENDENCIES']&.each do |name|
    spec.dependency name
  end

  yaml['FORWARD_DEPENDENCIES']&.each do |name, _|
    spec.dependency name
  end

end
