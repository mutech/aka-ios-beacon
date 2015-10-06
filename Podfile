source 'https://sources.aka-labs.com/scm/git/cocoapods'
source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AKA.xcworkspace'
xcodeproj 'AKACommons/AKACommons.xcodeproj'
xcodeproj 'AKAControls/AKAControls.xcodeproj'
xcodeproj 'AKAControls/AKAControlsGallery.xcodeproj'
xcodeproj 'AKAControlsDemo/AKAControlsDemo.xcodeproj'

use_frameworks!

platform :ios, '8.0'

target :AKACommons, :exclusive => true do
    pod 'CocoaLumberjack', '~> 2.0.1'
    target :AKACommonsTests, :exclusive => true do
	xcodeproj 'AKACommons/AKACommons.xcodeproj'
    end
    xcodeproj 'AKACommons/AKACommons.xcodeproj'
end

target :AKAControls, :exclusive => true do
    pod 'AKACommons', '~> 0.0.8' #:path => '.'
    target :AKAControlsTests, :exclusive => true do
        xcodeproj 'AKAControls/AKAControls.xcodeproj'
    end
    xcodeproj 'AKAControls/AKAControls.xcodeproj'
end

target :AKAControlsGallery, :exclusive => true do
    pod 'AKAControls', :path => '.'
    target :AKAControlsGalleryUITests do
        xcodeproj 'AKAControls/AKAControlsGallery.xcodeproj'
    end
    xcodeproj 'AKAControls/AKAControlsGallery.xcodeproj'
end

target :AKAControlsDemo, :exclusive => true do
    pod 'AKAControls', :path => '.'
    xcodeproj 'AKAControlsDemo/AKAControlsDemo.xcodeproj'
end

#post_install do |installer|
#    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
#        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
#    end
#end
