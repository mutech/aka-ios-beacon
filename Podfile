# This podfile is used for development and assumes that aka-ios-commons and aka-ios-beacon are
# checked out side-by-side.

source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AKABeacon.xcworkspace'
xcodeproj 'AKABeacon/AKABeacon.xcodeproj'
xcodeproj 'AKABeaconDemo/AKABeaconDemo.xcodeproj'

use_frameworks!

platform :ios, '8.2'

def commons_pods
    pod 'AKACommons', :path => '../aka-ios-commons'
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

# Using explicit versions to support pod try.
target :AKABeaconDemo, :exclusive => true do
    xcodeproj 'AKABeaconDemo/AKABeaconDemo.xcodeproj'
    beacon_pods
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end
