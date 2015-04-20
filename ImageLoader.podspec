Pod::Spec.new do |s|

  s.name         = "ImageLoader"
  s.version      = "0.3.2"
  s.summary      = "A lightweight and fast image loader for iOS written in Swift."
  s.description  = <<-DESC
                   ImageLoader is an instrument for asynchronous image loading written in Swift. It is a lightweight and fast image loader for iOS.
                   DESC

  s.homepage     = "https://github.com/hirohisa/ImageLoaderSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Hirohisa Kawasaki" => "hirohisa.kawasaki@gmail.com" }

  s.source       = { :git => "https://github.com/hirohisa/ImageLoaderSwift.git", :tag => s.version }

  s.source_files = "ImageLoader/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

end
