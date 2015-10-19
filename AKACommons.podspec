Pod::Spec.new do |spec|
    spec.name          = 'AKACommons'
    spec.version       = '0.0.9'
    spec.license       = { :type => 'PROPRIETARY', :text => <<-LICENSE
                   Copyright 2015 AKA Sarl. All rights reserved.
                   This is non-public work in progres. License terms are not yet determined. You should not see this!
LICENSE
               }
    spec.homepage      = 'https://www-akalabs.rhcloud.com/'
    spec.authors       = { 'Michael Utech' => 'michael.utech@aka-labs.com' }
    spec.summary       = 'Reusable components.'
    spec.source        = { :git => 'https://sources.aka-labs.com/scm/git/ios.aka.commons', :tag => 'v0.0.9-b002' }

    spec.source_files  = 'AKACommons/AKACommons/Classes/*.{h,m}'
    spec.private_header_files = 'AKACommons/AKACommons/Classes/*_Internal.h', 'AKACommons/AKACommons/AKACommons.h'

    spec.platform      = :ios, "8.0"
    spec.ios.deployment_target = "8.0"

    spec.framework     = 'Foundation'
    spec.module_name   = 'AKACommons'

#    spec.module_map    = 'AKACommons/AKACommons/modules.modulemap'
end
