# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'JMTimelineKit' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'AlamofireImage'
  pod 'SwiftyNSException'
  pod 'DTModelStorage', "~> 8.0.0"
  pod 'DTCollectionViewManager', "~> 7.1.0"
  pod 'TypedTextAttributes'
  pod 'AlamofireImage'
  pod 'SDWebImage'
  pod 'SDWebImage/WebP'
  pod 'lottie-ios'
  pod 'Fontello-Swift/Entypo', :git => 'git@github.com:bronenos/Fontello-Swift.git'
  pod 'JMRepicKit', :path => '../JMRepicKit'
  pod 'JMMarkdownKit', :path => '../JMMarkdownKit'
  pod 'JMOnetimeCalculator', :path => '../JMOnetimeCalculator'
  pod 'JMScalableView', :path => '../JMScalableView'
  pod 'JMDesignKit', :path => '../JMDesignKit'

end

post_install do |installer|
    migration = installer.pods_project.root_object.attributes
    migration['LastSwiftMigration'] = 9999
    migration['LastSwiftUpdateCheck'] = 9999
    migration['LastUpgradeCheck'] = 9999
    installer.pods_project.root_object.attributes = migration

    installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  end

        if ['Fontello-Swift'].include?(target.name)
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end
    end
end
