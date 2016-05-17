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

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

end

