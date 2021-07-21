Pod::Spec.new do |s|
  s.name             = "DLCaptureSession"
  s.version          = "0.2.0"
  s.summary          = "DLCaptureSession."
  s.homepage         = "https://github.com/sdkdimon/DLCaptureSession"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Dmitry Lizin" => "sdkdimon@gmail.com" }
  s.source           = { :git => "https://github.com/sdkdimon/DLCaptureSession.git", :tag => s.version }

  s.platform     = :ios, '11.0'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
  s.ios.frameworks = 'AVFoundation', 'UIKit'
  s.dependency 'CGImageTools', '1.0'

  s.module_name = 'DLCaptureSession'
  s.source_files = 'DLCaptureSession/DLCaptureSession/Source/*.{h,m}'

  s.subspec 'Categories' do |ss|
      ss.source_files = 'DLCaptureSession/DLCaptureSession/Source/Categories/*.{h,m}'
  end
end
