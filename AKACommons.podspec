Pod::Spec.new do |spec|
    spec.name          = 'AKACommons'
    spec.version       = '0.1.1-pre'
    spec.license       = 'BSD'
    spec.authors       = { 'Michael Utech' => 'michael.utech@aka-labs.com' }
    spec.homepage      = 'https://github.com/mutech/aka-ios-commons/'
    spec.summary       = 'Reusable components.'
    spec.source        = { :git => 'https://github.com/mutech/aka-ios-commons.git', :tag => spec.version.to_s }
    spec.source_files  = 'AKACommons/Classes/*.{h,m}'
    spec.private_header_files = 'AKACommons/Classes/*_Internal.h', 'AKACommons/AKATVRowSegment.h', 'AKACommons/AKATVSection.h', 'AKACommons/AKATVUpdateBatch.h'

    spec.platform      = :ios, "8.0"
    spec.ios.deployment_target = "8.0"

    spec.framework     = 'Foundation'
    spec.module_name   = 'AKACommons'

#    spec.module_map    = 'AKACommons/modules.modulemap'

    spec.dependency    'CocoaLumberjack', '~> 2.1.0'
end
