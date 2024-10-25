Pod::Spec.new do |s|
  s.name         = 'CPFantasy'
  s.version      = '0.1.0'
  s.summary      = 'A cricket fantasy App'
  s.description  = <<-DESC
                   Cricket based fantasy app
                   DESC
  s.homepage     = 'https://example.com/MyLibrary'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Your Name' => 'you@example.com' }
  s.source       = { :git => 'https://github.com/shikharoctal/octalfantasy.git', :tag => s.version.to_s }
  s.source_files = 'IndiaFantasy/Classes/**/*.{h,m,swift}'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.platform     = :ios, '13.0'
  s.dependency 'MaterialComponents'
  s.dependency 'Toast-Swift'
  s.dependency 'IQKeyboardManagerSwift'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'SDWebImage'
  s.dependency 'Firebase'
  s.dependency 'FirebaseCore'
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
  s.dependency 'SideMenu'
  s.dependency 'AMPopTip'
  s.dependency 'KeychainAccess'
  s.dependency 'Socket.IO-Client-Swift'
  s.dependency 'SwiftyAttributes'
  s.dependency 'DropDown'
  s.dependency 'CashfreePG'
  s.dependency 'EasyTipView'
  s.dependency 'GoogleSignIn'
  s.dependency 'lottie-ios'
  

end
