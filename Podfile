# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
# use_frameworks!

target 'ChachaT' do

use_frameworks!
pod "Koloda"

pod 'EFTools/Basic', :git => 'https://github.com/ElevenFifty/EFTools.git', :tag => '1.0'
pod 'Parse'
pod 'ParseUI'
pod 'MBAutoGrowingTextView', '~> 0.1.0'
pod 'STPopup'
pod 'Pages'
pod 'BlurryModalSegue'
pod "TTRangeSlider"
pod "Timepiece"
pod 'Ripple'

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

end

