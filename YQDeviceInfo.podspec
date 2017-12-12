Pod::Spec.new do |s|
  s.name         = "YQDeviceInfo"
  s.version      = "0.0.1"
  s.summary      = "iOS 设备信息 型号、版本、电量、cpu、内存等"

  s.homepage     = 'https://github.com/976431yang/YQDeviceInfo'
  s.license      = "MIT"
  s.author       = {'FreakyYang' => '1358970695@qq.com'}
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/976431yang/YQDeviceInfo.git" ,:tag => "#{s.version}"}
  s.public_header_files = "YQDeviceInfo/**/*.{h}"
  s.source_files  = "YQDeviceInfo/**/*.{h,m,mm}"
  
end
