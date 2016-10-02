# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
# use_frameworks!

target 'ChachaT' do

use_frameworks!

pod "Koloda", :git => 'https://github.com/Yalantis/Koloda.git', :branch => 'swift-3'
pod 'EFTools/Basic', :git => 'https://github.com/ElevenFifty/EFTools.git', :branch => 'swift-3'
pod 'Parse'
pod 'ParseUI'
pod 'STPopup'
pod "TTRangeSlider"
pod "Timepiece", :git => 'https://github.com/skofgar/Timepiece.git', :branch => 'swift3' #temporary fix. Some random guy converted the swift 3 code, so I am pointing to his for now, until the real timepiece cocoapod converts.
pod 'Ripple'
pod 'JSQMessagesViewController'
pod 'ParseFacebookUtilsV4'
pod 'Alamofire'
pod 'ExpandingMenu', '~> 0.1'
pod 'EZSwiftExtensions', :git => 'https://github.com/goktugyil/EZSwiftExtensions.git', :branch => 'Swift3'
pod 'MBAutoGrowingTextView', '~> 0.1.0'
pod 'RKNotificationHub'
pod 'SCLAlertView'
pod 'SnapKit'
pod 'AFBlurSegue', '~> 1.2.1'

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

end

