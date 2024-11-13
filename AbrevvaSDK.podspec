#
# Be sure to run `pod lib lint abrevva-sdk-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AbrevvaSDK'
  s.version          = '1.1.1'
  s.summary          = 'Official EVVA Abrevva iOS SDK'
  s.description      = <<-DESC
The EVVA Abrevva iOS SDK is a collection of tools to work with electronical EVVA access components.
It allows for scanning and connecting via BLE.
                       DESC

  s.homepage         = 'https://evva.com'
  s.license          = { :type => 'UNLICENSED', :file => 'LICENSE' }
  s.author           = 'EVVA Sicherheitstechnologie GmbH'
  s.source           = { :git => 'https://github.com/evva-sfw/abrevva-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.watchos.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.ios.dependency 'CocoaMQTT'
  s.dependency 'CryptoSwift'

  s.vendored_frameworks = 'AbrevvaSDK.xcframework'
end
