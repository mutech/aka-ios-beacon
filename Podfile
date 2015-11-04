source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AKABeacon.xcworkspace'
xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
xcodeproj 'AKABeacon/AKABeaconDemo.xcodeproj'

use_frameworks!

platform :ios, '8.0'

target :AKABeacon, :exclusive => true do
    target :AKABeaconTests, :exclusive => true do
        xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
    end
    xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
    pod 'AKACommons', '~> 0.1.0-pre.1'
end

target :AKABeaconDemo, :exclusive => true do
    target :AKABeaconDemoUITests do
        xcodeproj 'AKABeacon/AKABeaconDemo.xcodeproj'
    end
    xcodeproj 'AKABeacon/AKABeaconDemo.xcodeproj'
    pod 'AKABeacon', :path => '.'
    pod 'AKACommons', '~> 0.1.0-pre.1'
end
