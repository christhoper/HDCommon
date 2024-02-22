#
# Be sure to run `pod lib lint HDCommon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HDCommon'
  s.version          = '1.0.1'
  s.summary          = 'swift 开发中的一些基础公共库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  平时开发的基础工具等，方便组件化，避免重复造轮子；
                       DESC

  s.homepage         = 'https://github.com/christhoper/HDCommon'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hendy' => 'hdj309875551@163.com' }
  s.source           = { :git => 'https://github.com/christhoper/HDCommon.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  # 网络请求
  s.subspec "Networking" do |net|
      net.source_files = "HDCommon/HDCommon/Networking/**/*"
      net.dependency 'Alamofire'
  end
  
  # 扩展
  s.subspec "Extension" do |ext|
      ext.source_files = "HDCommon/HDCommon/Extension/**/*"
  end
  
  # s.resource_bundles = {
  #   'HDCommon' => ['HDCommon/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   
end
