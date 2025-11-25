Pod::Spec.new do |s|
  s.name           = 'ExpoLogger'
  s.version        = '1.0.0'
  s.summary        = 'Expo Logger module'
  s.description    = 'Expo Logger module'
  s.author         = 'Cargurus'
  s.homepage       = 'https://github.com/newarchspike/newarchspike'
  s.platforms      = {
    :ios => '15.1',
  }
  s.source         = { git: 'https://github.com/newarchspike/newarchspike.git', tag: '1.0.0' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
end
