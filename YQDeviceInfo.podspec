Pod::Spec.new do |s|
  s.name         = "YQDeviceInfo"
  s.version      = "0.0.1"
  s.summary      = "iOS 设备信息"

  s.description  = <<-DESC
                    WilddogDeviceInfo 的源码集成版本。供内部开发使用。
                   DESC

  s.homepage     = "https://www.wilddog.com/"
  s.license      = "MIT"
  s.author       = "Wilddog Team"
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/976431yang/YQDeviceInfo.git" ,:tag => "#{s.version}"}
  s.public_header_files = "YQDeviceInfo/**/*.{h}"
  s.source_files  = "YQDeviceInfo/**/*.{h,m,mm}"
  
end
