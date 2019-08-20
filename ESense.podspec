#
# Be sure to run `pod lib lint ESense.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ESense'
  s.version          = '0.1.2'
  s.summary          = 'This library allows us to use [eSense](http://www.esense.io/) (earable computing platform) on iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
 [eSense](http://www.esense.io/) is a multi-sensory earable platform for personal-scale behavioural analytics research. It is a True Wireless Stereo (TWS) earbud augmented with a 6-axis inertial motion unit, a microphone, and dual-mode Bluetooth (Bluetooth Classic and Bluetooth Low Energy). This library allows us to easily connect and communicate eSense on iOS.

                       DESC

  s.homepage         = 'https://github.com/tetujin/ESense'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yuuki Nishiyama' => 'yuukin@iis.u-tokyo.ac.jp' }
  s.source           = { :git => 'https://github.com/tetujin/ESense.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'ESense/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ESense' => ['ESense/Assets/*.png']
  # }

  s.swift_versions = '4.0'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreBluetooth'
  # s.dependency 'AFNetworking', '~> 2.3'
end
