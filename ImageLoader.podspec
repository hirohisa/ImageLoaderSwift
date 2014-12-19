Pod::Spec.new do |s|

  s.name         = "ImageLoader"
  s.version      = "0.1.1"
  s.summary      = "ImageLoader is an instrument for asynchronous image loading."
  s.description  = <<-DESC
                   ImageLoader is an instrument for asynchronous image loading written in Swift.
                   DESC

  s.homepage     = "https://github.com/hirohisa/ImageLoaderSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Hirohisa Kawasaki" => "hirohisa.kawasaki@gmail.com" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/hirohisa/ImageLoaderSwift.git", :tag => s.version }

  s.source_files = "ImageLoader/*.{h,swift}"
  s.frameworks   = "Swift"
  s.requires_arc = true

end
