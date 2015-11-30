source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AKABeacon.xcworkspace'
xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
xcodeproj 'AKABeacon/AKABeaconDemo.xcodeproj'

use_frameworks!

platform :ios, '8.2'

def commons_pods
    pod 'AKACommons', :path => '../aka-ios-commons'
    #pod 'AKACommons', :head
end

def beacon_pods
    commons_pods
    pod 'AKABeacon', :path => '.'
end

def testing_pods
end

def quicktesting_pods
	pod 'Quick', '~> 0.8.0'
	pod 'Nimble', '~> 3.0.0'
end

target :AKABeacon, :exclusive => true do
    target :AKABeaconTests, :exclusive => true do
        xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
	testing_pods
    end
    target :AKABeaconQuickTests, :exclusive => true do
        xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
	testing_pods
	quicktesting_pods
    end
    xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
    commons_pods
end

target :AKABeaconDemo, :exclusive => true do
    target :AKABeaconDemoUITests do
        xcodeproj 'AKABeacon/AKABeaconDemo.xcodeproj'
    end
    xcodeproj 'AKABeacon/AKABeaconDemo.xcodeproj'
    commons_pods
end
