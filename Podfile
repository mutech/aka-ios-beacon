source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AKAControls.xcworkspace'
xcodeproj 'AKAControls/AKAControls.xcodeproj'
xcodeproj 'AKAControls/AKAControlsGallery.xcodeproj'

use_frameworks!

platform :ios, '8.0'

target :AKAControls, :exclusive => true do
    target :AKAControlsTests, :exclusive => true do
        xcodeproj 'AKAControls/AKAControls.xcodeproj'
    end
    xcodeproj 'AKAControls/AKAControls.xcodeproj'
    pod 'AKACommons', '~> 0.1.0-pre.1'
end

target :AKAControlsGallery, :exclusive => true do
    target :AKAControlsGalleryUITests do
        xcodeproj 'AKAControls/AKAControlsGallery.xcodeproj'
    end
    xcodeproj 'AKAControls/AKAControlsGallery.xcodeproj'
    pod 'AKAControls', :path => '.'
    pod 'AKACommons', '~> 0.1.0-pre.1'
end
