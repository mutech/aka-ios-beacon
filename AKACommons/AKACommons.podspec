Pod::Spec.new do |spec|
    spec.name         = 'AKACommons'
    spec.version      = '0.0.1'
    spec.license      = 'Proprietary'
    spec.homepage     = 'https://www-akalabs.rhcloud.com/'
    spec.authors      = { 'Michael Utech' => 'michael.utech@aka-labs.com' }
    spec.summary      = 'Reusable components packaged with a control binding library.'
    spec.source       = { :git => 'https://sources.aka-labs.com/scm/git/ios.aka.commons', :tag => 'v0.0.1' }

    spec.source_files = '**/*.{h,m}'
    spec.private_header_files = '**/*_Internal.h'

    spec.platform     = :ios, "8.0"
    spec.ios.deployment_target = "8.0"

    spec.framework    = 'XCTest', 'Foundation'
    spec.module_name  = "AKACommons"

end
