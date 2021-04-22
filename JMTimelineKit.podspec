Pod::Spec.new do |spec|
    spec.name         = 'JMTimelineKit'
    spec.version      = '1.0.0'
    spec.license      = { :type => 'MIT' }
    spec.homepage     = 'https://github.com/bronenos'
    spec.authors      = { 'Stan Potemkin' => 'potemkin@jivosite.com' }
    spec.summary      = 'JMTimelineKit makes it easy to deal with chat feed.'

    spec.ios.deployment_target  = '10.0'

    spec.source       = { :git => '' }
    spec.source_files = 'JMTimelineKit/**/*.*'
    spec.resource = 'Assets.xcassets'

    spec.framework    = 'SystemConfiguration'

    spec.dependency     'AlamofireImage'
    spec.dependency     'SwiftyNSException'
    spec.dependency     'DTModelStorage', "~> 8.0.0"
    spec.dependency     'DTCollectionViewManager', "~> 7.1.0"
    spec.dependency     'TypedTextAttributes'
    spec.dependency     'AlamofireImage'
    spec.dependency     'SDWebImage'
    spec.dependency     'SDWebImage/WebP'
    spec.dependency     'lottie-ios'
    spec.dependency     'Fontello-Swift/Entypo'
    spec.dependency     'JMRepicKit'
    spec.dependency     'JMMarkdownKit'
    spec.dependency     'JMOnetimeCalculator'
    spec.dependency     'JMScalableView'

    spec.exclude_files = [
      'JMTimelineKit/Info.plist',
      'JMTimelineKit/Composite/ChatCompositeCellContentView.swift',
      'JMTimelineKit/Composite/JMTimelinePlayableCallEvent/JMTimelinePlayableCallEventContent.swift',
      'JMTimelineKit/Composite/JMTimelineRecordlessCallEvent/JMTimelineRecordlessCallEventContent.swift'
    ]
  end