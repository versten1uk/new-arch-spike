require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "ModuleInterop"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"] || "https://github.com"
  s.license      = package["license"]
  s.authors      = package["author"]
  s.platforms    = { :ios => "15.1" }
  s.source       = { :git => "https://github.com", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.public_header_files = "ios/ModuleInterop.h"
  
  # Required for Swift to import Objective-C module
  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES"
  }

  s.dependency "React-Core"
  s.dependency "ExpoLogger"
  s.dependency "TurboDeviceInfo"
  
  install_modules_dependencies(s)
end

