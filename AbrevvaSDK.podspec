#
# Be sure to run `pod lib lint abrevva-sdk-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AbrevvaSDK'
  s.version          = '1.0.15'
  s.summary          = 'Official EVVA Abrevva iOS SDK'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://bach1.evva.com/bitbucket/projects/XM/repos/abrevva-sdk-ios-pod'
  s.license          = { :type => 'UNLICENSED', :file => 'LICENSE' }
  s.author           = 'EVVA Sicherheitstechnologie GmbH'
  s.source           = { :git => 'https://bach1.evva.com/bitbucket/scm/xm/abrevva-sdk-ios-pod.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'

  s.dependency 'CocoaMQTT'
  s.dependency 'CryptoSwift'

  s.vendored_frameworks = 'AbrevvaSDK.framework'
end

