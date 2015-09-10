NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"

task :test do
  sh "carthage bootstrap"
  sh "xcodebuild clean test -workspace #{WORKSPACE} -scheme #{NAME} -sdk iphonesimulator"
end
