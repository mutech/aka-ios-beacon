Pod::Spec.new do |spec|
    spec.name          = 'AKAControls'
    spec.version       = '0.0.8'
    spec.license       = { :type => 'PROPRIETARY', :text => <<-LICENSE
                   Copyright 2015 AKA Sarl. All rights reserved.
                   This is non-public work in progres. License terms are not yet determined. You should not see this!
LICENSE
               }
    spec.homepage      = 'https://www-akalabs.rhcloud.com/'
    spec.authors       = { 'Michael Utech' => 'michael.utech@aka-labs.com' }
    spec.summary       = 'Form controls library with binding support and live rendering'
    spec.source        = { :git => 'https://sources.aka-labs.com/scm/git/ios.aka.commons', :tag => 'v0.0.8-b006' }

    spec.source_files  = 'AKAControls/AKAControls/Classes/*.{h,m}'
    #spec.private_header_files = '**/*_Internal.h'

    spec.platform      = :ios, "8.0"
    spec.ios.deployment_target = "8.0"

    spec.dependency    'AKACommons', '~> 0.0.8'
    spec.framework     = 'Foundation'
    spec.module_name   = 'AKAControls'

end
