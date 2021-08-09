inhibit_all_warnings!
use_frameworks!

target 'MBoxCocoapods' do
  podspec :subspec => 'Default'
end

target 'MBoxCocoapodsLoader' do
  podspec :subspec => 'Loader'
end
