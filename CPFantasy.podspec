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
  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.platform     = :ios, '13.0'
end
