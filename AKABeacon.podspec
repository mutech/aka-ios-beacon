Pod::Spec.new do |spec|
    spec.name          = 'AKABeacon'
    spec.version       = '0.1.0-pre.1'
    spec.license       = "GPL"
    spec.homepage      = 'https://www-akalabs.rhcloud.com/'
    spec.authors       = { 'Michael Utech' => 'michael.utech@aka-labs.com' }
    spec.summary       = 'Form controls library with binding support and live rendering'
    spec.source        = { :git => 'https://sources.aka-labs.com/scm/git/ios.aka.commons', :tag => spec.version.to_s }

    spec.source_files  = 'AKABeacon/AKABeacon/Classes/*.{h,m}'
    #spec.private_header_files = 'AKABeacon/AKABeacon/**/*_Internal.h', 'AKABeacon/AKABeacon/AKABeacon.h'

    spec.platform      = :ios, "8.0"
    spec.ios.deployment_target = "8.0"

    spec.dependency    'AKACommons', '~> 0.1.0-pre.1'
    spec.framework     = 'Foundation'
    spec.module_name   = 'AKAControls'

end