#
#  Be sure to run `pod spec lint DLoadingView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "DLoadingView"
  s.version      = "0.0.1"
  s.summary        =  "display different state of loading"
  s.description    = <<-DESC
			a long description of StateView in markdown format.
			DESC
 s.homepage     = "https://github.com/Chasingdreamboy/DLoadingView"
 s.license      = "MIT (example)"
 s.author             = { "Chasingdreamboy" => "15290411649@163.com" }
 s.platform     = :ios, "7.0"
 s.source       = { :git => "https://github.com/Chasingdreamboy/DLoadingView.git", :tag => "0.0.1" }
 s.source_files  = "*.h"
 s.preserve_paths = '*.m'
 #s.exclude_files = "StateView/Exclude"
 s.requires_arc = true

end
