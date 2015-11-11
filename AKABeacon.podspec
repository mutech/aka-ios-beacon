Pod::Spec.new do |spec|
    spec.name          = 'AKABeacon'
    spec.version       = '0.1.0-pre.2'
    spec.license       = 'GPL-v3'
    spec.homepage      = 'https://github.com/mutech/aka-ios-beacon/'
    spec.authors       = { 'Michael Utech' => 'michael.utech@aka-labs.com' }
    spec.summary       = 'The missing binding framework for iOS'
    spec.source        = { :git => 'https://github.com/mutech/aka-ios-beacon.git', :tag => spec.version.to_s }

    spec.source_files  = 'AKABeacon/AKABeacon/Classes/*.{h,m}', 'AKABeacon/AKABeacon/AKABeacon.h'
    spec.private_header_files = 'AKABeacon/AKABeacon/Classes/*_Internal.h', 'AKABeacon/AKABeacon/AKABeacon.h'

    spec.platform      = :ios, "8.2"
    spec.ios.deployment_target = "8.2"

    spec.framework     = 'Foundation'
    spec.module_name   = 'AKABeacon'

    spec.dependency    'AKACommons', '0.1.0.pre'
end
