#
# Be sure to run `pod lib lint NFCSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NFCSwift'
  s.version          = '1.0.0'
  s.summary          = 'NFC Full Swift Library for iOS'
  s.homepage         = 'https://github.com/ahmedadouani/NFCSwift'
  s.license          = { :type => "MIT" }
  s.author           = { 'Ahmed ADOUANI' => 'adouaniahmed@gmail.com' }

  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.source           = { :git => 'https://github.com/ahmedadouani/NFCSwift.git', :tag => s.version.to_s }
  s.source_files = 'NFCSwift/**/*.swift'
end
