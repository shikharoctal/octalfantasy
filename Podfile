# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CPFantasy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Toast-Swift'
  pod 'IQKeyboardManagerSwift'
  pod 'UITextView+Placeholder'
  pod 'NVActivityIndicatorView/Extended'
  pod 'SDWebImage'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Auth'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'FirebaseCore'
  pod 'Alamofire', '~> 5.3'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'SideMenu', '~> 6.0'
  pod 'AMPopTip'
  pod 'KeychainAccess'
  pod 'Socket.IO-Client-Swift', '~> 16.0'
  pod 'SwiftyAttributes'
  pod 'DropDown'
  pod 'CashfreePG', '~> 2.0.10'
  pod 'MaterialComponents/TextControls+FilledTextAreas'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'EasyTipView', '~> 2.1'
   # pod 'FBSDKCoreKit', '~> 15.1'
  #  pod 'FBSDKLoginKit', '~> 15.1'
  pod 'GoogleSignIn'
  pod 'lottie-ios'

#  pod 'FBSDKCoreKit'
  # Pods for CPFantasy

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
