NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"

task :test do
  sh "carthage bootstrap" #--no-use-binaries
  sh "xcodebuild -workspace #{WORKSPACE} -scheme #{NAME} -sdk iphonesimulator clean test"
end
