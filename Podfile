# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
# use_frameworks!

target 'Shuffles' do

use_frameworks!

pod "Koloda", :git => 'https://github.com/Yalantis/Koloda.git', :branch => 'swift-3'
pod 'EFTools/Basic', :git => 'https://github.com/ElevenFifty/EFTools.git', :branch => 'develop'
pod 'Parse'
pod 'ParseUI'
pod 'ParseLiveQuery', :git=> 'https://github.com/ParsePlatform/ParseLiveQuery-iOS-OSX.git'
pod "TTRangeSlider"
pod "Timepiece"
pod 'Ripple'
pod 'JSQMessagesViewController'
pod 'ParseFacebookUtilsV4', :git => 'https://github.com/white-rabbit-apps/ParseFacebookUtils-iOS.git' #pointing to a random fork that someone made because the original ParseFacebookUtilsV4 has a dependency lock on FacebookCore that is incompatible with GHBFacebookImagePicker. But, this fork has been updated to a better FacebookCoreDependency. If this public fork gets changed, or GHBFacebookImagePicker dependency number changes, then this would need to be updated to accomodate.
pod 'GBHFacebookImagePicker'
pod 'Alamofire'
pod 'ExpandingMenu', '~> 0.1'
pod 'EZSwiftExtensions'
pod 'MBAutoGrowingTextView', '~> 0.1.0'
pod 'RKNotificationHub'
pod 'SCLAlertView'
pod 'SnapKit'
pod 'TGLParallaxCarousel', :git=> 'https://github.com/danielchangsoojones/TGLParallaxCarousel.git' #had to fork of my own repo, so I (Daniel Jones) could customize some things
pod 'ALCameraViewController'
pod 'Instructions', git: 'https://github.com/ephread/Instructions.git', branch: 'swift3'
pod 'Static', git: 'https://github.com/venmo/Static'
pod "Former"
pod 'DatePickerDialog'

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

end

