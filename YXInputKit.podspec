#
# Be sure to run `pod lib lint YXInputKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'InputKit'
s.version          = '0.1.0'
s.summary          = 'Subclasses of UITextField and UITextView'
s.description      = 'Subclasses of UITextField and UITextView. Provide placeholder, secureTextEntry, clearView support for UITextField, so that UITextField and UITextView provide the ability to count words.'
s.homepage         = 'https://github.com/Jyhwenchai/InputKit'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Jyhwenchai' => 'cai5301@qq.com' }
s.source           = { :git => 'https://github.com/Jyhwenchai/InputKit.git', :tag => s.version.to_s }
s.ios.deployment_target = '9.0'
s.swift_version = '5.0'
s.source_files = 'InputKit/Classes/**/*'
end
